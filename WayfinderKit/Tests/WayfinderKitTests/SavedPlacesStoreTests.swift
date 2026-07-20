//
//  SavedPlacesStoreTests.swift
//  WayfinderKitTests
//
//  Verifies the favouriting source of truth: toggling a place in/out, and —
//  critically — that favourites persist across a "reload" (a fresh store
//  reading the same UserDefaults suite). This is the regression test for the
//  bug where saved places were a non-persisted @State array and reset on
//  every app launch.
//

import XCTest
import CoreLocation
@testable import WayfinderKit

@MainActor
final class SavedPlacesStoreTests: XCTestCase {

    /// Isolated suite so tests never touch the host app's real defaults.
    private var suite: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "test.savedplaces.\(UUID().uuidString)"
        suite = UserDefaults(suiteName: suiteName)
        suite.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        suite.removePersistentDomain(forName: suiteName)
        suite = nil
        suiteName = nil
        super.tearDown()
    }

    private func samplePlace(name: String, address: String) -> FinderPlace {
        FinderPlace(name: name, address: address,
                    location: CLLocation(latitude: -37.81, longitude: 144.96))
    }

    func testToggleAddsAndPersistsAcrossReload() {
        let pub = samplePlace(name: "The Pub", address: "1 Bar St")
        let store = SavedPlacesStore(defaults: suite)

        XCTAssertFalse(store.isSaved(pub))
        store.toggle(pub)
        XCTAssertTrue(store.isSaved(pub))

        // Simulate an app reload: a brand-new store reading the same suite.
        let reloaded = SavedPlacesStore(defaults: suite)
        XCTAssertTrue(reloaded.isSaved(pub),
                      "Favourite must survive a store reload (app restart).")
        XCTAssertEqual(reloaded.places.count, 1)
    }

    func testToggleRemovesFavouriteAndPersistsRemoval() {
        let pub = samplePlace(name: "The Pub", address: "1 Bar St")
        let store = SavedPlacesStore(defaults: suite)
        store.toggle(pub)
        XCTAssertTrue(store.isSaved(pub))

        store.toggle(pub)
        XCTAssertFalse(store.isSaved(pub))

        let reloaded = SavedPlacesStore(defaults: suite)
        XCTAssertFalse(reloaded.isSaved(pub),
                       "Unfavouriting must also survive a reload.")
        XCTAssertEqual(reloaded.places.count, 0)
    }

    func testToggleDoesNotDuplicateSameLogicalPlace() {
        let home = samplePlace(name: "Home", address: "42 Wallaby Way")
        let store = SavedPlacesStore(defaults: suite)

        // Toggle the same logical place twice (e.g. via the star on two rows
        // that map to the same name+address) — should never duplicate.
        store.toggle(home)
        store.toggle(home) // this removes it again
        store.toggle(home) // ...and adds it once more
        XCTAssertEqual(store.places.count, 1)
        XCTAssertTrue(store.isSaved(home))
    }

    func testStoreStartsEmptyWhenNothingPersisted() {
        let store = SavedPlacesStore(defaults: suite)
        XCTAssertTrue(store.places.isEmpty)
    }
}
