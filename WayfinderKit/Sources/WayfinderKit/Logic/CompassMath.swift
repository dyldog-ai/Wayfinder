//
//  CompassMath.swift
//  WayfinderKit
//
//  Pure, platform-agnostic compass/bearing geometry. No UIKit, no state — just
//  math, so it is trivially unit-testable and reusable from SwiftUI view models.
//

import CoreLocation

/// Namespaced, `public` compass geometry. The parallel formulas still live as
/// internal extensions on `Double` / `CLLocation` inside `UserLocationManager`
/// (used by the live CoreLocation manager); this enum is the decoupled,
/// testable surface the SwiftUI layer builds on.
public enum CompassMath {

    /// Degrees → radians.
    public static func radians(fromDegrees degrees: Double) -> Double {
        degrees * .pi / 180.0
    }

    /// Radians → degrees.
    public static func degrees(fromRadians radians: Double) -> Double {
        radians * 180.0 / .pi
    }

    /// Initial great-circle bearing (degrees, 0..<360, clockwise from true
    /// north) from `origin` to `destination`.
    public static func bearing(from origin: CLLocation,
                               to destination: CLLocation) -> CLLocationDirection {
        let fromLat = radians(fromDegrees: origin.coordinate.latitude)
        let fromLon = radians(fromDegrees: origin.coordinate.longitude)
        let toLat = radians(fromDegrees: destination.coordinate.latitude)
        let toLon = radians(fromDegrees: destination.coordinate.longitude)

        let y = sin(toLon - fromLon) * cos(toLat)
        let x = cos(fromLat) * sin(toLat)
            - sin(fromLat) * cos(toLat) * cos(toLon - fromLon)

        let bearing = degrees(fromRadians: atan2(y, x))
        return (bearing + 360.0).truncatingRemainder(dividingBy: 360.0)
    }

    /// Wrap an arbitrary angle into the canonical `[0, 360)` bearing range.
    /// Handles negative inputs and values `> 360` (e.g. `heading` passed as
    /// `360` or `-30`).
    public static func normalizeBearing(_ degrees: Double) -> CLLocationDirection {
        let r = degrees.truncatingRemainder(dividingBy: 360.0)
        return (r + 360.0).truncatingRemainder(dividingBy: 360.0)
    }

    /// Relative bearing (degrees, `0..<360`, clockwise) from the device's
    /// current `heading` (degrees clockwise from true north) to `destination`
    /// as seen from `origin`.
    ///
    /// A *relative* bearing is the angle you would turn, clockwise, to face the
    /// target: `absoluteBearing - heading`. The previous implementation returned
    /// `heading - bearing`, inverting the sign so the needle pointed to the
    /// mirror-image (port) side; it also skipped normalisation, yielding
    /// negative angles for `heading == 360` or negative heading inputs.
    ///
    /// Equivalent to the legacy `bearingBetween(heading:and:)` once that helper
    /// is corrected to the same convention.
    public static func relativeBearing(userHeading heading: CLLocationDirection,
                                       from origin: CLLocation,
                                       to destination: CLLocation) -> CLLocationDirection {
        normalizeBearing(bearing(from: origin, to: destination) - heading)
    }

    /// Human-readable distance string, matching the legacy
    /// `UserLocationManager.distanceString(to:)` formatting rules:
    /// `< 1 km` → whole metres ("m"), otherwise one-decimal kilometres ("km").
    public static func distanceString(meters: CLLocationDistance) -> String {
        switch Int(meters) {
        case 0...1000:
            return String(format: "%d m", Int(meters))
        default:
            return String(format: "%.1f km", meters / 1000.0)
        }
    }
}
