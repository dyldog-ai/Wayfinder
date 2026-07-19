//
//  WayfinderApp.swift
//  Wayfinder
//
//  SwiftUI app entry point. Owns the lifecycle (no AppDelegate / storyboard).
//  Builds the view models (logic task t_2e36b2c4) and injects them as
//  environment objects, plus the compass mode as an environment value so views
//  can adapt without reaching into the view model's private state.
//
//  LiveLocationProvider / MapKitLocationSearchProvider live in the app target
//  (they pull in CoreLocation / MapKit — neither is UIKit). The entry point
//  constructs them; previews use the in-package mock doubles. The compass
//  refresh hook pushes heading/destination/distance into the Dynamic Island
//  Live Activity.
//

import SwiftUI
import WayfinderKit
import CoreLocation

/// Environment value carrying the active compass mode, so views (e.g. whether
/// to show "Change Location") can adapt without reading CompassViewModel's
/// private `mode` property.
private struct CompassModeKey: EnvironmentKey {
    static let defaultValue: CompassMode = .userSelected
}

extension EnvironmentValues {
    var compassMode: CompassMode {
        get { self[CompassModeKey.self] }
        set { self[CompassModeKey.self] = newValue }
    }
}

@main
struct WayfinderApp: App {
    // The legacy Info.plist sets WFPlacesType = "multi", so we run in the
    // user-selected (multi-place) flow; the nearest-place flow would apply a
    // provider + .nearestPlace mode instead.
    private let mode: CompassMode = .userSelected

    @StateObject private var compass: CompassViewModel
    @StateObject private var searchVM: LocationSearchViewModel

    @MainActor
    init() {
        let location = LiveLocationProvider()
        let search = MapKitLocationSearchProvider()
        let mode: CompassMode = .userSelected
        let nearest: NearestPlaceProviding? = nil
        _compass = StateObject(wrappedValue: CompassViewModel(
            mode: mode, location: location, nearestProvider: nearest))
        _searchVM = StateObject(wrappedValue: LocationSearchViewModel(provider: search))

        // Push every refresh into the Dynamic Island / Lock Screen Live Activity.
        compass.onUpdate = { headingDegrees, destinationName, distanceString in
            guard #available(iOS 16.1, *) else { return }
            let label = CompassAttributes.cardinalLabel(for: headingDegrees)
            CompassLiveActivityManager.shared.startOrUpdate(
                headingDegrees: headingDegrees,
                headingLabel: label,
                destinationName: destinationName,
                distanceString: distanceString)
        }
    }

    var body: some Scene {
        WindowGroup {
            CompassView()
                .environmentObject(compass)
                .environmentObject(searchVM)
                .environment(\.compassMode, mode)
        }
    }
}
