//
//  MewseumApp.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import SwiftUI
import SwiftData

@main
struct MewseumApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Breed.self, WeightRange.self])
    }
}

// MARK: - Root view
private struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        BreedListView(
            viewModel: BreedListViewModel(modelContext: modelContext)
        )
    }
}
