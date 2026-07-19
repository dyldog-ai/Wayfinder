//
//  CompassViewModel.swift
//  WayfinderKit
//
//  SwiftUI-native replacement for the UIKit HeadingViewController hierarchy.
//  The old design spread state and behaviour across:
//    - HeadingViewController            (base: distance/destination labels, LA)
//    - SinglePlaceHeadingViewController (auto-find nearest place)
//    - MultiPlaceHeadingViewController  (user-picked destination, "North" idle)
//    - WayfinderView                    (needle-angle computation)
//    - UserLocationManager              (CoreLocation)
//
//  This ObservableObject centralises that state and exposes it as published,
//  render-ready values. It contains NO UIKit and NO view code.
//

import Foundation
import Combine
import CoreLocation

/// Which destination-selection behaviour the compass runs in — the SwiftUI
/// equivalent of the old CREATOR / MULTIPLACE / (default) compile flags that
/// switched `MainViewController`'s superclass.
public enum CompassMode: Equatable {
    /// Automatically point at the nearest relevant place (old single-place app).
    case nearestPlace
    /// Point at a user-selected place; when none is set, point north
    /// (old multi-place app).
    case userSelected
}

@MainActor
public final class CompassViewModel: ObservableObject {

    // MARK: Published render state

    /// Needle angle in radians (what the old `WayfinderView.headingAngle` held).
    @Published public private(set) var needleAngle: CGFloat = 0
    /// Destination display name, or the mode-appropriate idle title.
    @Published public private(set) var destinationTitle: String = ""
    /// Formatted distance ("350 m", "1.2 km"), or nil when there's no target.
    @Published public private(set) var distanceText: String?
    /// True once we have a target destination (drives distance-view visibility).
    @Published public private(set) var hasDestination: Bool = false
    /// Set when location permission is denied so the UI can leave "Searching...".
    @Published public private(set) var isAuthorizationDenied: Bool = false

    /// Current target, if any.
    @Published public private(set) var destination: FinderPlace?

    // MARK: Dependencies

    private let mode: CompassMode
    private let location: LocationProviding
    private let nearestProvider: NearestPlaceProviding?
    private var cancellables = Set<AnyCancellable>()

    /// Optional hook fired on every state refresh, used to push the Dynamic
    /// Island Live Activity (kept out of this type to avoid an ActivityKit
    /// dependency here). Mirrors `startOrUpdateCompassLiveActivity()`.
    public var onUpdate: ((_ headingDegrees: Double,
                           _ destinationName: String,
                           _ distanceString: String) -> Void)?

    public init(mode: CompassMode,
                location: LocationProviding,
                nearestProvider: NearestPlaceProviding? = nil,
                destination: FinderPlace? = nil) {
        self.mode = mode
        self.location = location
        self.nearestProvider = nearestProvider
        self.destination = destination
        self.hasDestination = destination != nil
        self.destinationTitle = destination?.name ?? Self.idleTitle(for: mode, denied: false)
    }

    /// Begin receiving location/heading updates. Call from `.onAppear`.
    public func start() {
        location.updates
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.handleUpdate() }
            .store(in: &cancellables)
        location.start()
        refresh()
    }

    /// Set a user-chosen destination (multi-place flow).
    public func selectDestination(_ place: FinderPlace?) {
        destination = place
        hasDestination = place != nil
        refresh()
    }

    // MARK: Update pipeline

    private func handleUpdate() {
        isAuthorizationDenied = location.isAuthorizationDenied

        // Single-place mode: if we have no destination yet, ask for the nearest.
        if mode == .nearestPlace, destination == nil,
           let here = location.latestLocation, let provider = nearestProvider {
            provider.searchNearest(near: here) { [weak self] places in
                guard let self else { return }
                Task { @MainActor in
                    if let first = places.first {
                        self.destination = first
                        self.hasDestination = true
                    }
                    self.refresh()
                }
            }
        }

        refresh()
    }

    /// Recompute all published render values from current inputs.
    private func refresh() {
        // Needle angle.
        if let heading = location.latestHeading {
            if let dest = destination?.location, let here = location.latestLocation {
                let deg = CompassMath.relativeBearing(userHeading: heading, from: here, to: dest)
                needleAngle = CGFloat(CompassMath.radians(fromDegrees: deg))
            } else {
                // No destination → point per mode: north (0) for user-selected
                // idle, current heading otherwise (matches legacy behaviour).
                let idle = idleHeading(currentHeading: heading)
                needleAngle = CGFloat(CompassMath.radians(fromDegrees: idle))
            }
        }

        // Titles + distance.
        if let dest = destination {
            destinationTitle = dest.name
            distanceText = location.distanceString(to: dest.location)
        } else {
            destinationTitle = Self.idleTitle(for: mode, denied: isAuthorizationDenied)
            distanceText = nil
        }

        // Live Activity hook.
        let headingDeg = Double(location.latestHeading ?? 0)
        onUpdate?(headingDeg, destination?.name ?? "", distanceText ?? "")
    }

    private func idleHeading(currentHeading: CLLocationDirection) -> CLLocationDirection {
        switch mode {
        case .userSelected:
            // Old MultiPlace idle points to current heading so the needle tracks
            // "North" as the phone rotates.
            return currentHeading
        case .nearestPlace:
            return currentHeading
        }
    }

    private static func idleTitle(for mode: CompassMode, denied: Bool) -> String {
        switch mode {
        case .userSelected:
            return "North"
        case .nearestPlace:
            return denied ? "Location access off" : "Searching..."
        }
    }
}
