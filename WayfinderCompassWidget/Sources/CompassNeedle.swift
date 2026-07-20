//
//  CompassNeedle.swift
//  WayfinderCompassWidget
//
//  Created by Dylan Elliott on 20/7/2026.
//

import SwiftUI
import WayfinderKit

struct CompassNeedle: View {
    let headingDegrees: Double
    let borderColor: Color = .white

    var body: some View {
        ZStack {
            Circle()
                .stroke(borderColor.opacity(0.5), lineWidth: 2)
            CompassGlyph(headingDegrees: headingDegrees)
                .padding(20)
        }
    }
}
