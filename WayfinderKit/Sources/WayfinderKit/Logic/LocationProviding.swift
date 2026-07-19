//
//  LocationProviding.swift
//  WayfinderKit
//
//  Protocol abstraction over live device location/heading, so SwiftUI view
//  models can depend on an interface (and be driven by a mock in previews /
//  tests) instead of the concrete `CLLocationManager`-backed type.
//

import Foundation
import Combine
import CoreLocation

/// A source of the user's latest location + heading, plus an authorization
/// signal. Mirrors the capability set the old `UserLocationManagerType` /
/// delegate pair exposed, but as an observable, Combine-friendly surface.
public protocol LocationProviding: AnyObject {
    var latestLocation: CLLocation? { get }
    var latestHeading: CLLocationDirection? { get }
    var isAuthorizationDenied: Bool { get }

    /// Emits whenever location or heading updates, or authorization changes.
    var updates: AnyPublisher<Void, Never> { get }

    /// Begin heading (and, when authorized, location) updates.
    func start()
}

public extension LocationProviding {
    /// Straight-line distance to `destination`, or nil if no fix yet.
    func distance(to destination: CLLocation) -> CLLocationDistance? {
        guard let here = latestLocation else { return nil }
        return here.distance(from: destination)
    }

    /// Formatted distance string (see `CompassMath.distanceString`).
    func distanceString(to destination: CLLocation) -> String? {
        guard let meters = distance(to: destination) else { return nil }
        return CompassMath.distanceString(meters: meters)
    }
}

/// Live implementation backed by the existing `UserLocationManager`. It adapts
/// the manager's delegate callbacks into a Combine publisher so the legacy
/// CoreLocation code stays the single source of truth for permissions/updates.
public final class LiveLocationProvider: NSObject, LocationProviding, UserLocationManagerDelegate {

    private let manager: UserLocationManager
    private let subject = PassthroughSubject<Void, Never>()

    public private(set) var isAuthorizationDenied: Bool = false

    public var latestLocation: CLLocation? { manager.latestLocation }
    public var latestHeading: CLLocationDirection? { manager.latestHeading }

    public var updates: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    public init(manager: UserLocationManager = .init()) {
        self.manager = manager
        super.init()
        self.manager.delegate = self
    }

    public func start() {
        manager.startLocationEvents()
    }

    // MARK: UserLocationManagerDelegate

    public func userLocationManagerDidUpdate() {
        subject.send(())
    }

    public func userLocationManagerAuthorizationDenied() {
        isAuthorizationDenied = true
        subject.send(())
    }
}
