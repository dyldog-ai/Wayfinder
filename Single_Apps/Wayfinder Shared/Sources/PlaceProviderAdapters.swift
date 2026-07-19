//
//  PlaceProviderAdapters.swift
//  Wayfinder
//
//  Bridges the existing delegate-based managers (GooglePlacesManager,
//  LocationSearchManager) to WayfinderKit's completion-based provider protocols
//  so the SwiftUI view models can consume them without knowing about Alamofire
//  or MapKit. These live in the app target because that's where the concrete
//  managers (and their third-party deps) live.
//

import Foundation
import CoreLocation
import WayfinderKit

/// Adapts `GooglePlacesManager` (delegate-based, coalesces one in-flight
/// request) to `NearestPlaceProviding`.
final class GooglePlacesNearestAdapter: NSObject, NearestPlaceProviding, GooglePlacesManagerDelegate {
    private let manager = GooglePlacesManager()
    private var pending: (([FinderPlace]) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
    }

    func searchNearest(near location: CLLocation,
                       completion: @escaping ([FinderPlace]) -> Void) {
        pending = completion
        manager.searchForBottleshops(near: location)
    }

    func didFindPlaces(_ places: [GooglePlace]) {
        let mapped = places.map {
            FinderPlace(name: $0.headableName(),
                        address: $0.headableAddress(),
                        location: $0.headableLocation())
        }
        let cb = pending
        pending = nil
        cb?(mapped)
    }
}

/// Adapts `LocationSearchManager` (MapKit, delegate-based) to
/// `LocationSearchProviding`.
final class MapKitLocationSearchAdapter: NSObject, LocationSearchProviding, LocationSearchManagerDelegate {
    private let manager = LocationSearchManager()
    private var pending: (([FinderPlace], String) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
    }

    func search(query: String,
                completion: @escaping ([FinderPlace], String) -> Void) {
        pending = completion
        manager.searchForLocationsWithString(searchText: query)
    }

    func locationSearchManagerDidFindPlaces(places: [FinderPlace], searchText: String) {
        let cb = pending
        pending = nil
        cb?(places, searchText)
    }
}
