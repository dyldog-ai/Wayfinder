//
//  CompassRoseView.swift
//  Wayfinder
//
//  Center compass rose. Wraps the existing UIKit Wayfinder UIView via the
//  `Wayfinder` UIViewRepresentable (WayfinderKit/Sources/WayfinderKit/Wayfinder.swift)
//  so the tuned needle drawing is reused during the rebuild. The needle angle is
//  driven by CompassViewModel + the WayfinderView's own location manager, so we
//  just hand it the destination and let it track. Swap this single view for a
//  pure-SwiftUI Canvas needle later if desired.
//

import SwiftUI
import WayfinderKit

struct CompassRoseView: View {
    @EnvironmentObject private var compass: CompassViewModel

    var body: some View {
        ZStack {
            WayfinderTheme.button
                .ignoresSafeArea()

            if let destination = compass.destination {
                Wayfinder(destination: destination) { _ in
                    // Heading/location updates are already piped through
                    // CompassViewModel.onUpdate via the app entry point.
                }
            } else {
                // No destination: show a north-pointing needle placeholder
                // rotated by the live needle angle from the view model.
                Image(systemName: "location.north.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(WayfinderTheme.arrow)
                    .rotationEffect(.radians(Double(compass.needleAngle)))
            }
        }
    }
}
