//
//  BreedListView.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import SwiftUI

// MARK: - Main View
struct BreedListView<ViewModel: BreedListViewModelProtocol>: View {
    @State var viewModel: ViewModel
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            BreedGridView(
                breeds: filteredBreeds,
                grid: viewModel.grid,
                isLoading: viewModel.isLoading
            )
            .refreshable {
                await viewModel.requestBreeds()
            }
            .navigationTitle("Mewseum")
            .searchable(text: $searchText, prompt: "Search breeds, origin, or temperament")
            .toolbar { BreedToolbar(viewModel: $viewModel) }
        }
        .task { await viewModel.requestBreeds() }
        .tint(Color.mewseumOrange)
    }

    // MARK: - Computed Properties
    private var filteredBreeds: [any BreedViewModelProtocol] {
        guard !searchText.isEmpty else {
            return viewModel.breeds
        }

        let queryTerms = searchText
            .split(whereSeparator: \.isWhitespace)
            .map { $0.normalize }
            .filter { !$0.isEmpty }

        return viewModel.breeds.filter { breed in
            let name = breed.name.normalize
            let origin = breed.origin.normalize
            let temperament = breed.temperament.normalize

            return queryTerms.allSatisfy { term in
                name.contains(term) ||
                origin.contains(term) ||
                temperament.contains(term)
            }
        }
    }
}

// MARK: - Grid View
private struct BreedGridView<Breed: BreedViewModelProtocol>: View {
    let breeds: [Breed]
    let grid: GridLayout
    var isLoading: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: grid.layout, spacing: 12.0) {
                ForEach(breeds, id: \.id) { breed in
                    BreedGridItem(
                        breed: breed,
                        grid: grid
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .overlay {
            if isLoading {
                ProgressView("Loading cats...")
                    .tint(.orange)
            }
        }
    }
}

// MARK: - Grid item
private struct BreedGridItem<ViewModel: BreedViewModelProtocol>: View {
    @Namespace private var namespace

    var breed: ViewModel
    let grid: GridLayout

    var body: some View {
        NavigationLink {
            BreedDetailView(viewModel: BreedDetailViewModel(breed: breed))
                .navigationTransition(
                    .zoom(sourceID: breed.id, in: namespace)
                )
        } label: {
            BreedCard(breed: breed, compact: grid == .three)
                .matchedTransitionSource(id: breed.id, in: namespace)
        }
    }
}

// MARK: - Breed Card
private struct BreedCard<ViewModel: BreedViewModelProtocol>: View {
    var breed: ViewModel
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            AsyncImage(url: URL(string: breed.imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: "cat.fill")
                            .foregroundStyle(.gray)
                            .font(.largeTitle)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: compact ? 120 : 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(breed.name)
                    .font(compact ? .subheadline : .headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                if !compact {
                    Text(breed.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Toolbar
private struct BreedToolbar<ViewModel: BreedListViewModelProtocol & Sendable>: ToolbarContent {
    @Binding var viewModel: ViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("🐱")
                .font(.title)
        }

        ToolbarItem(placement: .topBarTrailing) {
            gridLayoutButton
        }

        ToolbarItem(placement: .topBarTrailing) {
            sortMenu
        }
    }

    private var gridLayoutButton: some View {
        Button("", systemImage: viewModel.grid.otherIcon) {
            withAnimation(.bouncy) { viewModel.grid.toggle() }
        }
    }

    private var sortMenu: some View {
        Menu {
            Label("Sort by", systemImage: "arrow.up.and.down.text.horizontal")
            ForEach(BreedSortType.allCases) { type in
                Button {
                    Task { await viewModel.sort(by: type) }
                } label: {
                    Label(type.rawValue, systemImage: "textformat.abc")
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
        }
    }
}

// MARK: - Mewseum Colors
extension Color {
    static let mewseumOrange = Color(red: 1.0, green: 0.6, blue: 0.4) // #FF9966
    static let mewseumPink = Color(red: 1.0, green: 0.9, blue: 0.8) // #FFE5CC
    static let mewseumAccent = Color(red: 1.0, green: 0.42, blue: 0.21) // #FF6B35
}

// MARK: - Preview
#Preview {
    @Previewable
    @State var mockViewModel = MockBreedListViewModel()

    BreedListView(viewModel: mockViewModel)
}

// MARK: - Mock ViewModel for Preview
@MainActor
@Observable
final class MockBreedListViewModel: BreedListViewModelProtocol {
    var breeds: [BreedViewModel] = [
        BreedViewModel(breed: .mockAbyssinian)
    ]
    var isLoading: Bool = false
    var grid: GridLayout = .three

    func requestBreeds() async {
        // Mock implementation
    }

    func sort(by type: BreedSortType) async {
        // Mock implementation
    }
}
