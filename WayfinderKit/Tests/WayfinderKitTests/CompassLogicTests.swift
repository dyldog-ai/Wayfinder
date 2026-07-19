//
//  CompassLogicTests.swift
//  WayfinderKitTests
//
//  Unit tests for the ported, decoupled logic layer. These exercise pure math
//  and the ObservableObject state machine with mock providers — no CoreLocation
//  device access, no MapKit, no network.
//

import XCTest
import CoreLocation
import Combine
@testable import WayfinderKit

final class CompassMathTests: XCTestCase {

    func testDegreesRadiansRoundTrip() {
        let deg = 123.456
        let back = CompassMath.degrees(fromRadians: CompassMath.radians(fromDegrees: deg))
        XCTAssertEqual(back, deg, accuracy: 1e-9)
    }

    func testBearingDueNorth() {
        let origin = CLLocation(latitude: 0, longitude: 0)
        let north = CLLocation(latitude: 1, longitude: 0)
        XCTAssertEqual(CompassMath.bearing(from: origin, to: north), 0, accuracy: 0.001)
    }

    func testBearingDueEast() {
        let origin = CLLocation(latitude: 0, longitude: 0)
        let east = CLLocation(latitude: 0, longitude: 1)
        XCTAssertEqual(CompassMath.bearing(from: origin, to: east), 90, accuracy: 0.5)
    }

    func testBearingIsNormalisedToZero360() {
        let origin = CLLocation(latitude: 0, longitude: 0)
        let west = CLLocation(latitude: 0, longitude: -1)
        let b = CompassMath.bearing(from: origin, to: west)
        XCTAssertTrue(b >= 0 && b < 360)
        XCTAssertEqual(b, 270, accuracy: 0.5)
    }

    func testRelativeBearingSubtractsHeading() {
        let origin = CLLocation(latitude: 0, longitude: 0)
        let east = CLLocation(latitude: 0, longitude: 1) // bearing ~90
        // Facing east (90) → target dead ahead → relative ~0.
        let rel = CompassMath.relativeBearing(userHeading: 90, from: origin, to: east)
        XCTAssertEqual(rel, 0, accuracy: 0.5)
    }

    func testDistanceStringMetersUnderOneKm() {
        XCTAssertEqual(CompassMath.distanceString(meters: 350), "350 m")
    }

    func testDistanceStringKilometersOverOneKm() {
        XCTAssertEqual(CompassMath.distanceString(meters: 1234), "1.2 km")
    }
}

@MainActor
final class CompassViewModelTests: XCTestCase {

    private let melbourne = CLLocation(latitude: -37.8136, longitude: 144.9631)
    private let sydney = CLLocation(latitude: -33.8688, longitude: 151.2093)

    func testUserSelectedIdleShowsNorth() {
        let loc = MockLocationProvider(location: melbourne, heading: 0)
        let vm = CompassViewModel(mode: .userSelected, location: loc)
        vm.start()
        XCTAssertEqual(vm.destinationTitle, "North")
        XCTAssertFalse(vm.hasDestination)
        XCTAssertNil(vm.distanceText)
    }

    func testNearestPlaceIdleShowsSearching() {
        let loc = MockLocationProvider(location: melbourne, heading: 0)
        let vm = CompassViewModel(mode: .nearestPlace, location: loc,
                                  nearestProvider: MockNearestPlaceProvider(places: []))
        vm.start()
        XCTAssertEqual(vm.destinationTitle, "Searching...")
    }

    func testAuthorizationDeniedTitle() {
        let loc = MockLocationProvider(location: nil, heading: 0)
        let vm = CompassViewModel(mode: .nearestPlace, location: loc,
                                  nearestProvider: MockNearestPlaceProvider(places: []))
        vm.start()
        loc.denyAuthorization()
        // isAuthorizationDenied + destinationTitle are updated on the main
        // actor via receive(on: RunLoop.main); wait for the update to land.
        let exp = expectation(description: "authorization denied reflected")
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            if vm.isAuthorizationDenied && vm.destinationTitle == "Location access off" {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 2.0)
        timer.invalidate()
        XCTAssertTrue(vm.isAuthorizationDenied)
        XCTAssertEqual(vm.destinationTitle, "Location access off")
    }

    func testNearestPlaceAutoSelectsFirstResult() {
        let target = FinderPlace(name: "The Pub", address: "1 Bar St", location: sydney)
        let loc = MockLocationProvider(location: melbourne, heading: 0)
        let vm = CompassViewModel(mode: .nearestPlace, location: loc,
                                  nearestProvider: MockNearestPlaceProvider(places: [target]))
        vm.start()
        loc.emit() // trigger update → nearest search resolves via @MainActor task
        // The destination is set on the main actor inside an async Task, so poll
        // until it lands rather than checking once (a single check can run before
        // the task completes and then never re-check).
        let exp = expectation(description: "destination set")
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            if vm.hasDestination { exp.fulfill() }
        }
        wait(for: [exp], timeout: 2.0)
        timer.invalidate()
        XCTAssertEqual(vm.destination?.name, "The Pub")
        XCTAssertTrue(vm.hasDestination)
        XCTAssertNotNil(vm.distanceText)
    }

    func testUserSelectedDestinationUpdatesState() {
        let target = FinderPlace(name: "Home", address: "42 Wallaby Way", location: sydney)
        let loc = MockLocationProvider(location: melbourne, heading: 0)
        let vm = CompassViewModel(mode: .userSelected, location: loc)
        vm.start()
        vm.selectDestination(target)
        XCTAssertEqual(vm.destinationTitle, "Home")
        XCTAssertTrue(vm.hasDestination)
        XCTAssertNotNil(vm.distanceText)
    }

    func testLiveActivityHookFires() {
        let loc = MockLocationProvider(location: melbourne, heading: 45)
        let vm = CompassViewModel(mode: .userSelected, location: loc)
        var captured: (Double, String, String)?
        vm.onUpdate = { deg, name, dist in captured = (deg, name, dist) }
        vm.start()
        XCTAssertNotNil(captured)
        XCTAssertEqual(captured?.0, 45)
    }
}
