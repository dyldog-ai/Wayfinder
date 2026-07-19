//
//  CompassView.swift
//  Wayfinder
//
//  Root screen. Shows the destination name, the live compass rose, and the
//  distance. Presents the Location Selection sheet and the Hall of Fame alert.
//  State comes from the shared CompassViewModel (logic task t_2e36b2c4).
//

import SwiftUI
import WayfinderKit

struct CompassView: View {
    @EnvironmentObject private var compass: CompassViewModel

    @State private var showLocationSelection = false
    @State private var showHallOfFame = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DestinationInfoView()
                    .padding(.top, 8)

                CompassRoseView()
                    .padding(.vertical, 8)
                    .onLongPressGesture {
                        // Replaces MultiPlaceHeadingViewController.onHeadingViewLongPress
                        showHallOfFame = true
                    }

                DistanceInfoView(showLocationSelection: $showLocationSelection)
            }
            .background(WayfinderTheme.background)
            .navigationTitle("Wayfinder")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { compass.start() }
        }
        .sheet(isPresented: $showLocationSelection) {
            LocationSelectionView()
        }
        .alert("Thank you to…", isPresented: $showHallOfFame) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("""
            Robert N — For nudging me to add favourites
            """)
        }
    }
}

#Preview {
    CompassView()
        .environmentObject(CompassViewModel(
            mode: .userSelected,
            location: MockLocationProvider()))
        .environmentObject(LocationSearchViewModel(
            provider: MockLocationSearchProvider(places: [])))
        .environment(\.compassMode, .userSelected)
}
