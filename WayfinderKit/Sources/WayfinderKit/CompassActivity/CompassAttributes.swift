import Foundation
import ActivityKit

/// ActivityKit attributes describing a live compass session shown in the
/// Dynamic Island (and on the Lock Screen).
///
/// `ContentState` carries the values that change as the user moves; the
/// static `CompassAttributes` carries values fixed when the activity starts.
public struct CompassAttributes: ActivityAttributes {

    public typealias ContentState = State

    /// Values that update live as the user turns / moves.
    public struct State: Codable, Hashable {
        /// True heading the device is facing, in degrees (0 = north, clockwise).
        public var headingDegrees: Double
        /// Short cardinal label derived on the device, e.g. "N", "NE".
        public var headingLabel: String
        /// Name of the chosen destination (empty when none selected).
        public var destinationName: String
        /// Human-readable distance to the destination, e.g. "1.2 km".
        public var distanceString: String

        public init(headingDegrees: Double,
                    headingLabel: String,
                    destinationName: String,
                    distanceString: String) {
            self.headingDegrees = headingDegrees
            self.headingLabel = headingLabel
            self.destinationName = destinationName
            self.distanceString = distanceString
        }
    }

    /// Tint colour name (refers to an asset in the widget extension).
    public var tintColorName: String

    public init(tintColorName: String = "AccentColor") {
        self.tintColorName = tintColorName
    }
}

extension CompassAttributes {
    /// Convert a heading in degrees to a short cardinal label.
    public static func cardinalLabel(for degrees: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((degrees.truncatingRemainder(dividingBy: 360) + 22.5) / 45.0) % 8
        return directions[index]
    }
}
