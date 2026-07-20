import SwiftUI
import WidgetKit
import ActivityKit
import WayfinderKit

/// The Live Activity configuration. Rendered by the system in the Dynamic
/// Island (compact / minimal / expanded) and on the Lock Screen.
@available(iOS 16.1, *)
public struct CompassLiveActivity: Widget {
    public init() {}
    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: CompassAttributes.self) { context in
            CompassLockScreenView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        CompassNeedle(headingDegrees: context.state.headingDegrees)
                        Text(context.state.distanceString)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.destinationName.isEmpty ? "No destination" : context.state.destinationName)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(context.state.distanceString.isEmpty ? "–" : context.state.distanceString)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("\(Int(context.state.headingDegrees))°")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.destinationName.isEmpty
                          ? "Point your phone to find your way"
                          : "Heading to \(context.state.destinationName)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            } compactLeading: {
                CompassGlyph(headingDegrees: context.state.headingDegrees)
                    .padding(2)
            } compactTrailing: {
                Text(context.state.distanceString)
                    .font(.caption2.bold())
                    .foregroundColor(.white)
            } minimal: {
                CompassGlyph(headingDegrees: context.state.headingDegrees)
            }
            .widgetURL(URL(string: "wayfinder://compass"))
        }
    }
}
