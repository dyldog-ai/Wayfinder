//
//  LocationSelectionView.swift
//  Wayfinder
//
//  Modal sheet (replaces LocationSelectionViewController + the presented
//  UINavigationController segue). Lists search results while searching, or the
//  saved places otherwise. Tapping a row selects it as the destination via the
//  shared CompassViewModel; the star toggles a saved place; "Clear Location"
//  clears the destination.
//
//  Search is driven by the LocationSearchViewModel injected as an environment
//  object from WayfinderApp (logic task). Saved places are held locally here
//  with a TODO to back them with @AppStorage("SAVED_PLACES") (the legacy
//  persistence) — lift into a model when the logic task adds one.
//

import SwiftUI
import WayfinderKit

struct LocationSelectionView: View {
    @EnvironmentObject private var compass: CompassViewModel
    @EnvironmentObject private var searchVM: LocationSearchViewModel
    @Environment(\.dismiss) private var dismiss

    // TODO(logic): back with @AppStorage("SAVED_PLACES") once a model exists.
    @State private var savedPlaces: [FinderPlace] = []

    private var displayedPlaces: [FinderPlace] {
        searchVM.query.trimmingCharacters(in: .whitespaces).isEmpty
            ? savedPlaces
            : searchVM.results
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField("Search", text: $searchVM.query)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                Divider()
                    .background(WayfinderTheme.h2.opacity(0.2))

                List {
                    Section(searchVM.query.isEmpty ? "Saved Places" : "Search Results") {
                        ForEach(displayedPlaces, id: \.id) { place in
                            PlaceRowView(
                                name: place.name,
                                address: place.address,
                                isStarred: savedPlaces.contains(where: { $0.id == place.id })
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                compass.selectDestination(place)
                                dismiss()
                            }
                            .swipeActions {
                                Button {
                                    toggleSaved(place)
                                } label: {
                                    Image(systemName: savedPlaces.contains(where: { $0.id == place.id }) ? "star.slash.fill" : "star.fill")
                                }
                                .tint(.yellow)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .background(WayfinderTheme.background)

                Button {
                    compass.selectDestination(nil)
                    dismiss()
                } label: {
                    Text("Clear Location")
                        .font(.custom("Arial Rounded MT Bold", size: 15))
                        .foregroundColor(WayfinderTheme.button)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(WayfinderTheme.toolbar)
            }
            .background(WayfinderTheme.toolbar)
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func toggleSaved(_ place: FinderPlace) {
        if let index = savedPlaces.firstIndex(where: { $0.id == place.id }) {
            savedPlaces.remove(at: index)
        } else {
            savedPlaces.append(place)
        }
        // TODO(logic): persist savedPlaces to @AppStorage("SAVED_PLACES").
    }
}
