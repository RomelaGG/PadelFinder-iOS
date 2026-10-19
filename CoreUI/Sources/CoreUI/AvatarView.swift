//
//  AvatarView.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - AvatarView

/// A circular profile image, or the initials that stand in for one.
///
/// `imageURL` is here for the day the backend returns an avatar — today
/// `UserResponse` carries no image of any kind, so in practice this always
/// renders initials.
public struct AvatarView: View {

    public enum Size {
        case small
        case large

        var side: CGFloat {
            switch self {
            case .small: return PadelDesignTokens.Sizing.avatarSmall
            case .large: return PadelDesignTokens.Sizing.avatarLarge
            }
        }

        var font: Font {
            switch self {
            case .small: return PadelDesignTokens.Fonts.callout
            case .large: return PadelDesignTokens.Fonts.largeTitle
            }
        }
    }

    private let imageURL: URL?
    private let initials: String
    private let size: Size

    public init(imageURL: URL?, initials: String, size: Size = .small) {
        self.imageURL = imageURL
        self.initials = initials
        self.size = size
    }

    public var body: some View {
        Group {
            if let imageURL {
                RemoteImage(url: imageURL, maxPixelSize: size.side * 3) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    fallback
                }
            } else {
                fallback
            }
        }
        .frame(width: size.side, height: size.side)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }

    private var fallback: some View {
        ZStack {
            PadelDesignTokens.Colors.accentSurface

            if initials.isEmpty {
                Image(systemName: "person.fill")
                    .font(.system(size: size.side * 0.45, weight: .regular))
                    .foregroundStyle(PadelDesignTokens.Colors.textSecondary)
            } else {
                Text(initials)
                    .font(size.font)
                    .foregroundStyle(PadelDesignTokens.Colors.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
    }
}

#Preview {
    HStack(spacing: PadelDesignTokens.Spacing.xxxl) {
        AvatarView(imageURL: nil, initials: "GR", size: .large)
        AvatarView(imageURL: nil, initials: "G", size: .small)
        AvatarView(imageURL: nil, initials: "", size: .large)
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
