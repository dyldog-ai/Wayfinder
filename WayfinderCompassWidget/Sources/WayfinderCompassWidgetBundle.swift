import SwiftUI
import WidgetKit
import WayfinderKit

@main
struct WayfinderCompassWidgetBundle: WidgetBundle {
    var body: some Widget {
        CompassLiveActivity()
    }
}
