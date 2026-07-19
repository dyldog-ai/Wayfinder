//
//  PlacesProviding.swift
//  WayfinderKit
//
//  Abstractions over the two place-discovery mechanisms in the legacy app:
//    - GooglePlacesManager  → nearest open place of a configured type
//    - LocationSearchManager (MapKit) → free-text location search
//  Concrete adapters live in the app target (they pull in Alamofire / MapKit);
//  the SwiftUI view models depend only on these protocols.
//

import Foundation
import CoreLocation

/// Finds the single nearest relevant place to a coordinate (the old
/// "single place" / auto-find flow, e.g. nearest bottleshop).
public protocol NearestPlaceProviding: AnyObject {
    /// Search near `location`; completion delivers ordered-by-distance results
    /// (may be empty). Implementations should coalesce concurrent requests.
    func searchNearest(near location: CLLocation,
                       completion: @escaping ([FinderPlace]) -> Void)
}

/// Free-text location search (the old MapKit `LocationSearchManager`, used by
/// the multi-place flow's location picker).
public protocol LocationSearchProviding: AnyObject {
    /// Search for `query`; completion delivers matching places (may be empty).
    func search(query: String,
                completion: @escaping (_ places: [FinderPlace], _ query: String) -> Void)
}
