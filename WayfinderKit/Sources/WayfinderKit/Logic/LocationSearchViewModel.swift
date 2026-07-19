//
//  LocationSearchViewModel.swift
//  WayfinderKit
//
//  SwiftUI replacement for LocationSelectionViewController's logic: takes search
//  text, drives a LocationSearchProviding, and publishes results. No UI.
//

import Foundation
import Combine

@MainActor
public final class LocationSearchViewModel: ObservableObject {

    @Published public var query: String = ""
    @Published public private(set) var results: [FinderPlace] = []

    private let provider: LocationSearchProviding
    private var cancellables = Set<AnyCancellable>()

    public init(provider: LocationSearchProviding) {
        self.provider = provider
        // Debounce keystrokes, then search (the old VC searched on each edit).
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in self?.performSearch(text) }
            .store(in: &cancellables)
    }

    private func performSearch(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            return
        }
        provider.search(query: trimmed) { [weak self] places, searchedQuery in
            Task { @MainActor in
                // Ignore stale responses (old query no longer current).
                guard let self, searchedQuery == self.query.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
                self.results = places
            }
        }
    }
}
