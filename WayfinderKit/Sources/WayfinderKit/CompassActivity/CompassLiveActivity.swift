import SwiftUI
import WidgetKit
import ActivityKit

/// A small rotating compass needle used in the Dynamic Island and Lock Screen.
struct CompassNeedle: View {
    let headingDegrees: Double
    var color: Color = .white

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.5), lineWidth: 2)
                .frame(width: 36, height: 36)
            Image(systemName: "location.north.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundColor(color)
                .rotationEffect(.degrees(headingDegrees))
        }
    }
}

/// Compact glyph for the minimal Dynamic Island presentation.
struct CompassGlyph: View {
    let headingDegrees: Double

    var body: some View {
        CompassNeedle(headingDegrees: headingDegrees, color: .white)
            .frame(width: 18, height: 18)
    }
}

/// Lock Screen / notification presentation of the compass activity.
@available(iOS 16.1, *)
struct CompassLockScreenView: View {
    let state: CompassAttributes.State

    var body: some View {
        HStack(spacing: 12) {
            CompassNeedle(headingDegrees: state.headingDegrees)
            VStack(alignment: .leading, spacing: 2) {
                Text(state.destinationName.isEmpty ? "No destination" : state.destinationName)
                    .font(.headline)
                    .foregroundColor(.white)
                HStack {
                    Text("Heading \(state.headingLabel) · \(Int(state.headingDegrees))°")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    if !state.distanceString.isEmpty {
                        Text("· \(state.distanceString)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(red: 0.173, green: 0.243, blue: 0.314))
    }
}

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
