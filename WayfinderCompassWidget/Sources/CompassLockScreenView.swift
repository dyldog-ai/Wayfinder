//
//  CompassLockScreenView.swift
//  WayfinderCompassWidget
//
//  Created by Dylan Elliott on 20/7/2026.
//

import SwiftUI
import WayfinderKit

@available(iOS 16.1, *)
struct CompassLockScreenView: View {
    let state: CompassAttributes.State

    var body: some View {
        HStack(spacing: 12) {
            CompassNeedle(headingDegrees: state.headingDegrees)
            VStack(alignment: .leading, spacing: 2) {
                Text(state.destinationName.isEmpty ? "No destination" : state.destinationName)
                    .font(.headline)
                    .foregroundColor(.white)
                HStack {
                    Text("Heading \(state.headingLabel) · \(Int(state.headingDegrees))°")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    if !state.distanceString.isEmpty {
                        Text("· \(state.distanceString)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(red: 0.173, green: 0.243, blue: 0.314))
    }
}
