//
//  MockProviders.swift
//  WayfinderKit
//
//  Deterministic test/preview doubles for the logic-layer protocols. These make
//  CompassViewModel / LocationSearchViewModel drivable with no CoreLocation,
//  MapKit, or network — enabling unit tests and SwiftUI previews.
//

import Foundation
import Combine
import CoreLocation

public final class MockLocationProvider: LocationProviding {
    public var latestLocation: CLLocation?
    public var latestHeading: CLLocationDirection?
    public var isAuthorizationDenied: Bool = false

    private let subject = PassthroughSubject<Void, Never>()
    public var updates: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    public init(location: CLLocation? = CLLocation(latitude: -37.840935, longitude: 144.946457),
                heading: CLLocationDirection? = 0) {
        self.latestLocation = location
        self.latestHeading = heading
    }

    public func start() { emit() }

    /// Push a new fix and notify observers (drives view-model updates in tests).
    public func emit(location: CLLocation? = nil, heading: CLLocationDirection? = nil) {
        if let location { latestLocation = location }
        if let heading { latestHeading = heading }
        subject.send(())
    }

    public func denyAuthorization() {
        isAuthorizationDenied = true
        subject.send(())
    }
}

public final class MockNearestPlaceProvider: NearestPlaceProviding {
    public var places: [FinderPlace]
    public init(places: [FinderPlace]) { self.places = places }
    public func searchNearest(near location: CLLocation,
                              completion: @escaping ([FinderPlace]) -> Void) {
        completion(places)
    }
}

public final class MockLocationSearchProvider: LocationSearchProviding {
    public var places: [FinderPlace]
    public init(places: [FinderPlace]) { self.places = places }
    public func search(query: String,
                       completion: @escaping ([FinderPlace], String) -> Void) {
        completion(places, query)
    }
}
