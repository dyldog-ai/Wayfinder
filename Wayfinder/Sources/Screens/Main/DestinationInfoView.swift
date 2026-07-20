//
//  DestinationInfoView.swift
//  Wayfinder
//
//  Top info bar. Mirrors HeadingViewController.destinationView: a title
//  ("DESTINATION") above the destination name, or the idle title
//  (CompassViewModel.destinationTitle) when no destination is selected.
//

import SwiftUI
import WayfinderKit

struct DestinationInfoView: View {
    @EnvironmentObject private var compass: CompassViewModel

    var body: some View {
        VStack(spacing: 2) {
            Text("DESTINATION")
                .font(.custom("Arial Rounded MT Bold", size: 17))
                .foregroundColor(WayfinderTheme.h1)
            Text(compass.destinationTitle)
                .font(.custom("Arial Rounded MT Bold", size: 28))
                .foregroundColor(WayfinderTheme.h2)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(WayfinderTheme.toolbar)
    }
}
