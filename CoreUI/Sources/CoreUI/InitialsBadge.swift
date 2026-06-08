//
//  InitialsBadge.swift
//  CoreUI
//
//  Created by Giorgi Romelashvili on 02.06.26.
//

import DesignSystem
import SwiftUI

public struct InitialsBadge: View {
    private let title: String
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let lineColor: Color

    public init(
        title: String,
        backgroundColor: Color,
        foregroundColor: Color,
        lineColor: Color
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.lineColor = lineColor
    }

    public var body: some View {
        ZStack {
            backgroundColor

            courtLines
                .padding(PadelDesignTokens.Spacing.xl)

            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(foregroundColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var courtLines: some View {
        GeometryReader { proxy in
            let size = proxy.size

            Path { path in
                path.addRect(CGRect(origin: .zero, size: size))
                path.move(to: CGPoint(x: size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: size.width / 2, y: size.height))
                path.move(to: CGPoint(x: 0, y: size.height / 2))
                path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
            }
            .stroke(lineColor, lineWidth: PadelDesignTokens.Sizing.hairline)
        }
    }
}
