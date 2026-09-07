//
//  ScrollOverscrollReader.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 07.09.26.
//

import SwiftUI
import UIKit

// MARK: - View

public extension View {
    /// Reports how far the scroll view this is applied to is dragged past its top
    /// edge, in points.
    ///
    /// Reads `0` whenever the scroll view rests at (or below) the top, whatever
    /// safe areas or navigation chrome the screen sits in — unlike a
    /// `GeometryReader` reading `.global`, whose zero depends on that context.
    func onTopOverscrollChange(_ action: @escaping (CGFloat) -> Void) -> some View {
        background(ScrollOverscrollReader { distance, _ in action(distance) })
    }
}

// MARK: - ScrollOverscrollReader

/// Bridges the enclosing `UIScrollView`'s content offset back into SwiftUI.
///
/// Installed as a background, so it lands beside the scroll view it measures and
/// covers the same area — which is how it tells that scroll view apart from any
/// nested one, such as a horizontal row of pills.
struct ScrollOverscrollReader: UIViewRepresentable {
    /// Called with the top over-scroll distance and whether a finger is still down.
    let onChange: (CGFloat, Bool) -> Void

    func makeUIView(context: Context) -> ScrollProbeView {
        let view = ScrollProbeView()
        view.onChange = onChange

        return view
    }

    func updateUIView(_ view: ScrollProbeView, context: Context) {
        view.onChange = onChange
    }
}

// MARK: - ScrollProbeView

final class ScrollProbeView: UIView {
    var onChange: ((CGFloat, Bool) -> Void)?

    private weak var scrollView: UIScrollView?
    private var observation: NSKeyValueObservation?
    private var lastReport: (distance: CGFloat, isTracking: Bool)?

    override func layoutSubviews() {
        super.layoutSubviews()

        // Frames are what identify the scroll view, and they only settle once laid
        // out — so keep looking until the match is found.
        observeEnclosingScrollView()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard window == nil else { return }

        observation = nil
        scrollView = nil
    }
}

// MARK: - Observing

private extension ScrollProbeView {
    func observeEnclosingScrollView() {
        guard scrollView == nil, let enclosing = enclosingScrollView() else { return }

        scrollView = enclosing
        observation = enclosing.observe(\.contentOffset) { [weak self] scrollView, _ in
            MainActor.assumeIsolated {
                self?.report(scrollView)
            }
        }
    }

    /// The scroll view this probe backs: the tightest one around it, looked for
    /// from the closest ancestor outwards.
    func enclosingScrollView() -> UIScrollView? {
        let probeFrame = convert(bounds, to: nil)

        guard !probeFrame.isEmpty else { return nil }

        var ancestor = superview

        while let current = ancestor {
            if let match = current.innermostScrollView(covering: probeFrame) { return match }

            ancestor = current.superview
        }

        return nil
    }

    func report(_ scrollView: UIScrollView) {
        let distance = max(0, -(scrollView.contentOffset.y + scrollView.adjustedContentInset.top))
        let isTracking = scrollView.isTracking

        // Scrolling anywhere below the top reports zero over and over; only pass on
        // what actually changed, so ordinary scrolling costs no SwiftUI updates.
        guard lastReport?.distance != distance || lastReport?.isTracking != isTracking else { return }

        lastReport = (distance, isTracking)

        guard scrollView.isMoving else {
            // Offsets the system adjusts — insets resolving, content resizing — can
            // arrive inside SwiftUI's update pass, where changing state is undefined
            // behaviour. Hand those over on the next turn instead.
            Task { @MainActor [weak self] in
                self?.onChange?(distance, isTracking)
            }

            return
        }

        // Offsets driven by the finger land outside the update pass, so they go
        // straight through: a deferred stretch would lag the content by a frame.
        onChange?(distance, isTracking)
    }
}

// MARK: - UIScrollView

private extension UIScrollView {
    /// Whether the current offset comes from the user rather than from layout.
    var isMoving: Bool {
        isTracking || isDragging || isDecelerating
    }
}

// MARK: - UIView

private extension UIView {
    /// Tolerance for a scroll view "covering" a frame: a background sits inside the
    /// safe area while its scroll view runs under it, so the two rarely match exactly.
    static let coverageTolerance: CGFloat = 40

    /// The smallest scroll view among this view's descendants that covers `frame`.
    func innermostScrollView(covering frame: CGRect) -> UIScrollView? {
        var queue = subviews
        var candidates: [UIScrollView] = []

        while !queue.isEmpty {
            let view = queue.removeFirst()

            if let scrollView = view as? UIScrollView, scrollView.covers(frame) {
                candidates.append(scrollView)
            }

            queue.append(contentsOf: view.subviews)
        }

        return candidates.min { $0.bounds.area < $1.bounds.area }
    }

    func covers(_ frame: CGRect) -> Bool {
        let ownFrame = convert(bounds, to: nil)
            .insetBy(dx: -Self.coverageTolerance, dy: -Self.coverageTolerance)

        return ownFrame.contains(frame)
    }
}

// MARK: - CGRect

private extension CGRect {
    var area: CGFloat { width * height }
}
