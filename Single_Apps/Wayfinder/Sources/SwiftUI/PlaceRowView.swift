//
//  PlaceRowView.swift
//  Wayfinder
//
//  One row in the Location Selection list. Mirrors LocationTableViewCell:
//  name (H2), address (H1), and a star button (handled by the parent via
//  swipeActions in LocationSelectionView).
//

import SwiftUI

struct PlaceRowView: View {
    let name: String
    let address: String
    let isStarred: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.custom("Arial Rounded MT Bold", size: 17))
                    .foregroundColor(WayfinderTheme.h2)
                Text(address)
                    .font(.custom("Arial Rounded MT Bold", size: 12))
                    .foregroundColor(WayfinderTheme.h1)
            }
            Spacer(minLength: 0)
            Image(systemName: isStarred ? "star.fill" : "star")
                .foregroundColor(.yellow)
        }
        .padding(.vertical, 8)
        .listRowBackground(WayfinderTheme.background)
    }
}
