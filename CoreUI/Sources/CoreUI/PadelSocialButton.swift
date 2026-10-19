//
//  PadelSocialButton.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import DesignSystem
import SwiftUI

// MARK: - PadelSocialButton

/// A provider sign-in button that is not Apple's.
///
/// The enum has one case today. It exists so that when a second provider
/// arrives, no call site changes shape.
public struct PadelSocialButton: View {

    public enum Provider {
        case google

        var title: String {
            switch self {
            case .google: return "Continue with Google"
            }
        }
    }

    private let provider: Provider
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        provider: Provider,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.provider = provider
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: PadelDesignTokens.Spacing.l) {
                mark

                Text(provider.title)
                    .font(PadelDesignTokens.Fonts.callout)
                    .foregroundStyle(PadelDesignTokens.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: PadelDesignTokens.Sizing.actionControl)
            .background(PadelDesignTokens.Colors.surface)
            .clipShape(shape)
            .overlay {
                shape.stroke(
                    PadelDesignTokens.Colors.borderStrong,
                    lineWidth: PadelDesignTokens.Sizing.hairline
                )
            }
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!isLoading)
        .accessibilityLabel(isLoading ? "\(provider.title), loading" : provider.title)
    }

    @ViewBuilder
    private var mark: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(PadelDesignTokens.Colors.textSupport)
                .frame(width: 20, height: 20)
        } else {
            switch provider {
            case .google:
                GoogleMark()
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)
            }
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: PadelDesignTokens.Radius.xl, style: .continuous)
    }
}

// MARK: - GoogleMark

/// The four-colour G, drawn as four arcs of one ring plus the blue bar.
///
/// Geometry is taken from the mark in `design-mockups.html`, normalised to a
/// 24pt box: ring centred at 12,12 with a 7.8 mid-radius and 4.4 thickness,
/// split at the four angles below, and the bar running from the centre out to
/// the right edge. Drawn rather than bundled because `CoreUI` ships no
/// resources, and an asset catalogue for one 20pt glyph is not worth the
/// package-manifest change.
private struct GoogleMark: View {

    private struct Segment {
        let color: Color
        let start: Double
        let end: Double
    }

    /// Degrees, clockwise from the 3 o'clock position.
    private let segments: [Segment] = [
        Segment(color: Color(red: 0.26, green: 0.52, blue: 0.96), start: 312.2, end: 408.8),
        Segment(color: Color(red: 0.20, green: 0.66, blue: 0.33), start: 48.8, end: 153.3),
        Segment(color: Color(red: 0.98, green: 0.74, blue: 0.02), start: 153.3, end: 206.7),
        Segment(color: Color(red: 0.92, green: 0.26, blue: 0.21), start: 206.7, end: 312.2)
    ]

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let unit = side / 24
            let center = CGPoint(x: side / 2, y: side / 2)

            ZStack {
                ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: 7.8 * unit,
                            startAngle: .degrees(segment.start),
                            endAngle: .degrees(segment.end),
                            clockwise: false
                        )
                    }
                    .stroke(
                        segment.color,
                        style: StrokeStyle(lineWidth: 4.4 * unit, lineCap: .butt)
                    )
                }

                Path { path in
                    path.addRect(
                        CGRect(
                            x: 12 * unit,
                            y: 10.29 * unit,
                            width: 9.6 * unit,
                            height: 3.71 * unit
                        )
                    )
                }
                .fill(Color(red: 0.26, green: 0.52, blue: 0.96))
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    VStack(spacing: PadelDesignTokens.Spacing.xl) {
        PadelSocialButton(provider: .google) {}
        PadelSocialButton(provider: .google, isLoading: true) {}

        GoogleMark()
            .frame(width: 64, height: 64)
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
