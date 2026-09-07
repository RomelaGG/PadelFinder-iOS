//
//  RemoteImage.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 07.09.26.
//

import ImageIO
import SwiftUI
import UIKit

/// Drop-in replacement for `AsyncImage` that decodes (and downsamples) off the
/// main thread and keeps the result in memory.
///
/// `AsyncImage` hands SwiftUI an undecoded image, so the first frame that shows
/// it pays for the full JPEG decode on the main thread — which reads as a short
/// stall if it lands while the user is scrolling.
public struct RemoteImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let maxPixelSize: CGFloat?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var image: UIImage?

    /// - Parameter maxPixelSize: longest edge, in pixels, the image is
    ///   downsampled to while decoding. Defaults to the screen's longest edge.
    public init(
        url: URL?,
        maxPixelSize: CGFloat? = nil,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.maxPixelSize = maxPixelSize
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            if let image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .task(id: url) { await load() }
    }

    private func load() async {
        guard let url else {
            image = nil
            return
        }

        let size = maxPixelSize ?? RemoteImageCache.defaultMaxPixelSize
        if let cached = RemoteImageCache.shared.cachedImage(for: url, maxPixelSize: size) {
            image = cached
            return
        }

        let loaded = await RemoteImageCache.shared.image(for: url, maxPixelSize: size)
        guard !Task.isCancelled else { return }

        // No implicit animation: the image can land mid-scroll.
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { image = loaded }
    }
}

// MARK: - Cache

@MainActor
final class RemoteImageCache {
    static let shared = RemoteImageCache()

    static var defaultMaxPixelSize: CGFloat {
        let screen = UIScreen.main
        return max(screen.bounds.width, screen.bounds.height) * screen.scale
    }

    private let cache = NSCache<NSString, UIImage>()
    private var inFlight: [NSString: Task<UIImage?, Never>] = [:]

    func cachedImage(for url: URL, maxPixelSize: CGFloat) -> UIImage? {
        cache.object(forKey: Self.key(url, maxPixelSize))
    }

    func image(for url: URL, maxPixelSize: CGFloat) async -> UIImage? {
        let key = Self.key(url, maxPixelSize)
        if let cached = cache.object(forKey: key) { return cached }

        let task = inFlight[key] ?? {
            let task = Task.detached(priority: .userInitiated) { () -> UIImage? in
                guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
                return Self.decode(data, maxPixelSize: maxPixelSize)
            }
            inFlight[key] = task
            return task
        }()

        let image = await task.value
        inFlight[key] = nil
        if let image { cache.setObject(image, forKey: key) }
        return image
    }

    private static func key(_ url: URL, _ maxPixelSize: CGFloat) -> NSString {
        "\(url.absoluteString)|\(Int(maxPixelSize))" as NSString
    }

    /// Decodes on the calling thread, so it must stay off the main actor.
    private nonisolated static func decode(_ data: Data, maxPixelSize: CGFloat) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
