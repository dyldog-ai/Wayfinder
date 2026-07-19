//
//  DistanceInfoView.swift
//  Wayfinder
//
//  Bottom info bar. Mirrors HeadingViewController.bottomView/distanceView:
//  a "DISTANCE" title above the live distance (CompassViewModel.distanceText),
//  and a "Change Location" button that opens the Location Selection sheet.
//  The button is shown only in user-selected (.userSelected) mode — the
//  single-place (nearestPlace) flow hides it, matching
//  SinglePlaceHeadingViewController. The mode comes from the `compassMode`
//  environment value (CompassViewModel's `mode` is private).
//

import SwiftUI

struct DistanceInfoView: View {
    @EnvironmentObject private var compass: CompassViewModel
    @Environment(\.compassMode) private var mode
    @Binding var showLocationSelection: Bool

    var body: some View {
        VStack(spacing: 5) {
            VStack(spacing: 0) {
                Text("DISTANCE")
                    .font(.custom("Arial Rounded MT Bold", size: 17))
                    .foregroundColor(WayfinderTheme.h1)
                Text(compass.distanceText ?? "0 km")
                    .font(.custom("Arial Rounded MT Bold", size: 20))
                    .foregroundColor(WayfinderTheme.h2)
            }

            if mode == .userSelected {
                Button {
                    showLocationSelection = true
                } label: {
                    Text("Change Location")
                        .font(.custom("Arial Rounded MT Bold", size: 15))
                        .foregroundColor(WayfinderTheme.button)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(WayfinderTheme.toolbar)
    }
}
