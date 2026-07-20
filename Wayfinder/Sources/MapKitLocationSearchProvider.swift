//
//  MapKitLocationSearchProvider.swift
//  Wayfinder
//
//  UIKit-free, MapKit-backed location search. Replaces the old
//  `LocationSearchManager` (a UIKit delegate-based manager) and its
//  `MapKitLocationSearchAdapter`. Uses `MKLocalSearch` directly — no UIKit,
//  no Alamofire. Drives LocationSearchViewModel via the `LocationSearchProviding`
//  protocol from WayfinderKit.
//

import Foundation
import MapKit
import CoreLocation
import WayfinderKit

/// Adapts `MKLocalSearch` (free-text local search) to `LocationSearchProviding`.
@MainActor
final class MapKitLocationSearchProvider: NSObject, LocationSearchProviding {
    func search(query: String,
                completion: @escaping ([FinderPlace], String) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response else {
                completion([], query)
                return
            }
            let places = response.mapItems.compactMap { item -> FinderPlace? in
                guard let location = item.placemark.location else { return nil }
                let name = item.name ?? item.placemark.title ?? "Unknown"
                let address = [
                    item.placemark.thoroughfare,
                    item.placemark.locality,
                ].compactMap { $0 }.joined(separator: ", ")
                return FinderPlace(name: name, address: address, location: location)
            }
            completion(places, query)
        }
    }
}
