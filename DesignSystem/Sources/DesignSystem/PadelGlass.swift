//
//  PadelGlass.swift
//  DesignSystem
//
//  Created by Giorgi Romelashvili on 18.10.26.
//

import SwiftUI

// MARK: - PadelGlassFallback

/// What stands in for Liquid Glass below iOS 26.
public enum PadelGlassFallback {
    /// `.ultraThinMaterial` — for controls that float over scrolling content.
    case material

    /// An opaque fill, for places where a material reads muddy.
    case solid(Color)
}

// MARK: - padelGlass

public extension View {
    /// Liquid Glass on iOS 26, `fallback` below it.
    ///
    /// Every availability check for glass lives in this one file, so no component has to
    /// write the branch twice.
    ///
    /// Reserve this for the floating navigation layer — bars, sheets, and controls that
    /// hover above content. Content itself (cards, fields, pills, banners) stays solid:
    /// glass over content costs text contrast and reads as glass-on-glass.
    @ViewBuilder
    func padelGlass<S: Shape>(
        in shape: S,
        tint: Color? = nil,
        interactive: Bool = false,
        fallback: PadelGlassFallback = .material
    ) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(
                Glass.regular
                    .tint(tint)
                    .interactive(interactive),
                in: shape
            )
        } else {
            modifier(PadelGlassFallbackModifier(shape: shape, fallback: fallback))
        }
    }
}

// MARK: - PadelGlassFallbackModifier

private struct PadelGlassFallbackModifier<S: Shape>: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let shape: S
    let fallback: PadelGlassFallback

    /// iOS 26 honours Reduce Transparency inside `glassEffect` itself. The material
    /// fallback does not, so it has to be handled here.
    @ViewBuilder
    func body(content: Content) -> some View {
        switch fallback {
        case .material:
            if reduceTransparency {
                content.background(PadelDesignTokens.Colors.surface, in: shape)
            } else {
                content.background(.ultraThinMaterial, in: shape)
            }

        case let .solid(color):
            content.background(color, in: shape)
        }
    }
}
