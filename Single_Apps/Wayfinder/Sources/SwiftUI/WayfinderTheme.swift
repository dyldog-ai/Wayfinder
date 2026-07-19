//
//  WayfinderTheme.swift
//  Wayfinder
//
//  Centralised colour palette for the SwiftUI rebuild.
//

import SwiftUI

enum WayfinderTheme {
    /// Dark navy — top/bottom info bars, search bar background.
    static let toolbar     = Color(red: 0.071, green: 0.122, blue: 0.161)
    /// Green — main canvas, table background, divider.
    static let background   = Color(red: 0.243, green: 0.557, blue: 0.341)
    /// Red — full-screen canvas behind the compass, "Change Location" title.
    static let button       = Color(red: 0.906, green: 0.298, blue: 0.239)
    /// White — section titles ("DESTINATION", "DISTANCE").
    static let h1           = Color.white
    /// Grey — destination name, distance value.
    static let h2           = Color(white: 0.604)
    /// Arrow red (matches the old HeadingView tint #E74C3D).
    static let arrow        = Color(red: 0.906, green: 0.298, blue: 0.239)
}
