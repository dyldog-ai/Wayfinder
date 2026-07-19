import Foundation
import ActivityKit

/// Starts, updates, and ends the compass Live Activity.
///
/// Safe to call on iOS < 16.1 — every public entry point early-returns when
/// ActivityKit is unavailable, so the app can keep its lower deployment
/// target for non-Dynamic-Island devices.
@available(iOS 16.1, *)
public final class CompassLiveActivityManager {

    public static let shared = CompassLiveActivityManager()

    private var activity: Activity<CompassAttributes>?

    private init() {}

    /// Begin the activity if it isn't running yet, otherwise push the latest
    /// values into the existing one.
    public func startOrUpdate(headingDegrees: Double,
                              headingLabel: String,
                              destinationName: String,
                              distanceString: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let state = CompassAttributes.State(headingDegrees: headingDegrees,
                                            headingLabel: headingLabel,
                                            destinationName: destinationName,
                                            distanceString: distanceString)

        if let existing = activity ?? Activity<CompassAttributes>.activities.first {
            self.activity = existing
            Task { await existing.update(using: state) }
            return
        }

        do {
            let new = try Activity<CompassAttributes>.request(
                attributes: CompassAttributes(),
                contentState: state,
                pushType: nil)
            self.activity = new
        } catch {
            print("Compass Live Activity failed to start: \(error)")
        }
    }

    /// Push fresh values into the running activity (no-op if none is running).
    public func update(headingDegrees: Double,
                       headingLabel: String,
                       destinationName: String,
                       distanceString: String) {
        startOrUpdate(headingDegrees: headingDegrees,
                      headingLabel: headingLabel,
                      destinationName: destinationName,
                      distanceString: distanceString)
    }

    /// Dismiss the running activity.
    public func end() {
        guard let activity = activity ?? Activity<CompassAttributes>.activities.first else { return }
        Task { await activity.end(dismissalPolicy: .immediate) }
        self.activity = nil
    }
}
