//
//  CompassRoseView.swift
//  Wayfinder
//
//  Center compass rose. Draws a pure-SwiftUI needle rotated by the live
//  `needleAngle` published by CompassViewModel (radians; 0 = pointing up/north).
//  This replaces the old UIKit `Wayfinder` UIViewRepresentable bridge and its
//  `WayfinderView`/`HeadingView` CoreGraphics needle — no UIKit involved.
//

import SwiftUI
import WayfinderKit

struct CompassRoseView: View {
    @EnvironmentObject private var compass: CompassViewModel

    var body: some View {
        ZStack {
            WayfinderTheme.background
                .ignoresSafeArea()

            DrawnCompassNeedle()
                .scaledToFit()
                .padding(40)
                .foregroundColor(WayfinderTheme.arrow)
                .rotationEffect(.radians(Double(compass.needleAngle)))
        }
    }
}
