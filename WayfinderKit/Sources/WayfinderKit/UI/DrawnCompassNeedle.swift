//
//  DrawnCompassNeedle.swift
//  WayfinderKit
//
//  Created by Dylan Elliott on 20/7/2026.
//
//  A pure-SwiftUI, cartoon-style compass needle. The outline is an upward
//  arrow (isosceles triangle) with a triangular notch cut out of its base,
//  giving it the classic two-pronged compass look. The needle is split down
//  its centre line into two halves, each filled with a different shade of the
//  main colour so it reads with a bit of depth.
//

import SwiftUI

public struct DrawnCompassNeedle: View {
    /// The main colour of the needle. One half is drawn in this colour, the
    /// other in a lighter shade of it.
    var colors: (Color, Color) = (.init(hex: "D65746"), .init(hex: "A0483B"))
    
    let offsetRatioY: CGFloat = -0.07

    /// How far up the notch is cut from the base, as a fraction of the height.
    private let notchDepth: CGFloat = 0.28
    
    public init() { }

    public var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let offsetY = h * offsetRatioY

            let apex = CGPoint(x: w / 2, y: offsetY)
            let bottomLeft = CGPoint(x: 0, y: h + offsetY)
            let bottomRight = CGPoint(x: w, y: h + offsetY)
            let notch = CGPoint(x: w / 2, y: h - h * notchDepth + offsetY)

            ZStack {
                // Left half — the main colour.
                Path { path in
                    path.move(to: apex)
                    path.addLine(to: bottomLeft)
                    path.addLine(to: notch)
                    path.closeSubpath()
                }
                .fill(colors.0)

                // Right half — a lighter shade of the main colour.
                Path { path in
                    path.move(to: apex)
                    path.addLine(to: bottomRight)
                    path.addLine(to: notch)
                    path.closeSubpath()
                }
                .fill(colors.1)
            }
        }
        // Keep the needle tall and slim regardless of the frame it's given.
        .aspectRatio(0.75, contentMode: .fit)
    }
}

#Preview {
    DrawnCompassNeedle()
        .frame(width: 120, height: 240)
        .padding()
}
