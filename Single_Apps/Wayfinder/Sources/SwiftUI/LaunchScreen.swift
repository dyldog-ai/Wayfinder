//
//  LaunchScreen.swift
//  Wayfinder
//
//  Optional SwiftUI launch screen mirroring LaunchScreen.storyboard
//  (toolbar-coloured bars top & bottom, green canvas between). Not wired by
//  default — Xcode still uses the storyboard unless Info.plist adopts
//  UILaunchScreen. Left here so the launch UI can be SwiftUI-ified later.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            WayfinderTheme.background
            VStack(spacing: 0) {
                WayfinderTheme.toolbar.frame(height: 88)
                Spacer()
                WayfinderTheme.toolbar.frame(height: 44)
            }
        }
        .ignoresSafeArea()
    }
}
