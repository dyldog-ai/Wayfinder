//
//  CompassGlyph.swift
//  WayfinderCompassWidget
//
//  Created by Dylan Elliott on 20/7/2026.
//

import SwiftUI
import WayfinderKit

struct CompassGlyph: View {
    let headingDegrees: Double

    var body: some View {
        DrawnCompassNeedle()
            .rotationEffect(.degrees(headingDegrees))
    }
}
