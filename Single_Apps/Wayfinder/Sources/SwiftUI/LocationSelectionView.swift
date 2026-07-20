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
//  object from WayfinderApp (logic task). Favourites are owned by the injected
//  SavedPlacesStore (logic layer), which persists them to UserDefaults so they
//  survive app reloads — previously they were a non-persisted @State array and
//  reset every time the sheet closed.
//

import SwiftUI
import WayfinderKit

struct LocationSelectionView: View {
    @EnvironmentObject private var compass: CompassViewModel
    @EnvironmentObject private var searchVM: LocationSearchViewModel
    @EnvironmentObject private var savedPlaces: SavedPlacesStore
    @Environment(\.dismiss) private var dismiss

    private var displayedPlaces: [FinderPlace] {
        searchVM.query.trimmingCharacters(in: .whitespaces).isEmpty
            ? savedPlaces.places
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
                                isStarred: savedPlaces.isSaved(place)
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
                                    Image(systemName: savedPlaces.isSaved(place) ? "star.slash.fill" : "star.fill")
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
        savedPlaces.toggle(place)
    }
}
