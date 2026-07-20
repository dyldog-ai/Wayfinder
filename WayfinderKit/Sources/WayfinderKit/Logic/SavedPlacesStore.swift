//
//  SavedPlacesStore.swift
//  WayfinderKit
//
//  Persistent store for the user's favourite (starred) places.
//
//  The UI previously held the favourites list in a `@State` array that was
//  never written anywhere, so favouriting reset every time the selection
//  sheet closed and was lost entirely on app reload. This store owns the
//  source of truth: it JSON-encodes `[FinderPlace]` into a `UserDefaults`
//  suite (the app's standard suite by default) and reloads it on init, so
//  favourites survive process restarts.
//
//  It is `@MainActor` / `ObservableObject` so SwiftUI views can bind to
//  `places` and re-render on change, mirroring `LocationSearchViewModel`
//  and `CompassViewModel`.
//

import Foundation
import CoreLocation

@MainActor
public final class SavedPlacesStore: ObservableObject {

    /// The current set of favourited places, in the order they were added.
    @Published public private(set) var places: [FinderPlace]

    private let defaults: UserDefaults
    private let key: String

    public init(defaults: UserDefaults = .standard, key: String = "SAVED_PLACES") {
        self.defaults = defaults
        self.key = key
        self.places = SavedPlacesStore.decode(from: defaults, forKey: key)
    }

    /// Whether `place` is currently favourited. Identity is by `FinderPlace.id`
    /// (name + address), so re-adding the same logical place is a no-op toggle.
    public func isSaved(_ place: FinderPlace) -> Bool {
        places.contains(where: { $0.id == place.id })
    }

    /// Add `place` if it isn't favourited, or remove it if it is. Persists
    /// immediately so the change survives an app reload.
    public func toggle(_ place: FinderPlace) {
        if let index = places.firstIndex(where: { $0.id == place.id }) {
            places.remove(at: index)
        } else {
            places.append(place)
        }
        persist()
    }

    /// Replace the whole set (used to clear). Persists immediately.
    public func set(_ newPlaces: [FinderPlace]) {
        places = newPlaces
        persist()
    }

    private func persist() {
        defaults.set(try? JSONEncoder().encode(places), forKey: key)
    }

    private static func decode(from defaults: UserDefaults, forKey key: String) -> [FinderPlace] {
        (defaults.object(forKey: key) as? Data)
            .flatMap { try? JSONDecoder().decode([FinderPlace].self, from: $0) }
            ?? []
    }
}
