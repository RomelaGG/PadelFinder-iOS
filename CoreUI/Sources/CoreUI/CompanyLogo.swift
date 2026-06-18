//
//  CompanyLogo.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 18.06.26.
//

import DesignSystem
import SwiftUI

public struct CompanyLogo: View {
    private let content: AnyView
    private let size: CGFloat

    public init(
        logoURL: URL?,
        title: String,
        backgroundColor: Color,
        foregroundColor: Color,
        lineColor: Color,
        size: CGFloat = PadelDesignTokens.Sizing.mediaThumbnail
    ) {
        self.content = AnyView(
            RemoteCompanyLogo(
                logoURL: logoURL,
                title: title,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                lineColor: lineColor
            )
        )
        self.size = size
    }

    public init<Content: View>(
        size: CGFloat = PadelDesignTokens.Sizing.mediaThumbnail,
        @ViewBuilder content: () -> Content
    ) {
        self.content = AnyView(content())
        self.size = size
    }

    public var body: some View {
        content
            .frame(width: size, height: size)
            .background(PadelDesignTokens.Colors.surfaceMuted)
            .clipShape(shape)
            .overlay {
                shape
                    .stroke(
                        PadelDesignTokens.Colors.border,
                        lineWidth: PadelDesignTokens.Sizing.hairline
                    )
            }
            .shadow(
                color: PadelDesignTokens.Colors.shadowLow,
                radius: PadelDesignTokens.Shadow.lowRadius,
                x: PadelDesignTokens.Shadow.lowX,
                y: PadelDesignTokens.Shadow.lowY
            )
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: PadelDesignTokens.Radius.xl,
            style: .continuous
        )
    }
}

private struct RemoteCompanyLogo: View {
    let logoURL: URL?
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let lineColor: Color

    var body: some View {
        if let logoURL {
            AsyncImage(url: logoURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    fallbackLogo
                @unknown default:
                    fallbackLogo
                }
            }
        } else {
            fallbackLogo
        }
    }

    private var fallbackLogo: some View {
        InitialsBadge(
            title: title,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            lineColor: lineColor
        )
    }
}

#Preview {
    VStack(spacing: PadelDesignTokens.Spacing.xxl) {
        CompanyLogo(
            logoURL: nil,
            title: "RC",
            backgroundColor: .green,
            foregroundColor: .white,
            lineColor: .white.opacity(0.2)
        )

        CompanyLogo {
            Image(systemName: "building.2.fill")
                .resizable()
                .scaledToFill()
        }
    }
    .padding()
    .background(PadelDesignTokens.Colors.background)
}
