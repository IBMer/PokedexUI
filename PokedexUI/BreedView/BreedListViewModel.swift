import Foundation
import SwiftData
import SwiftUI

/// Protocol defining the observable view model for the Breed list screen.
///
/// Provides access to the list of breeds, loading state, and methods to fetch and sort breed data.
@MainActor
protocol BreedListViewModelProtocol {
    /// The currently loaded breeds displayed in the grid.
    var breeds: [BreedViewModel] { get }
    /// A flag indicating whether data is currently being fetched.
    var isLoading: Bool { get }
    /// The current grid layout used for displaying breeds.
    var grid: GridLayout { get set }

    /// Asynchronously requests breeds from the backend service.
    func requestBreeds() async
    /// Sorts the current breed list using a specific sorting type.
    /// - Parameter type: The sorting strategy to use.
    func sort(by type: BreedSortType) async
}

// MARK: -
/// Default implementation of the breed list view model, responsible for loading and exposing breed data and UI state.
@Observable
final class BreedListViewModel {
    // MARK: Private Properties
    /// Service used to fetch breed data.
    private let breedService: BreedServiceProtocol
    private let storageReader: DataStorageReader

    // MARK: - Public properties
    /// The current list of breeds, updated after each successful fetch.
    var breeds: [BreedViewModel] = []

    /// Indicates whether a data request is in progress.
    var isLoading: Bool = false

    /// The breed grid layout.
    var grid: GridLayout = .three

    // MARK: - Initialization
    /// Creates a new `BreedListViewModel`.
    ///
    /// - Parameters:
    ///   - modelContext: The SwiftData model context to use for persistence.
    ///   - breedService: A `BreedService` instance. Defaults to using mock data.
    init(modelContext: ModelContext, breedService: BreedService = BreedService()) {
        self.storageReader = DataStorageReader(modelContainer: modelContext.container)
        self.breedService = breedService
    }
}

// MARK: - BreedListViewModelProtocol
extension BreedListViewModel: BreedListViewModelProtocol {
    /// Requests breeds from storage or API.
    ///
    /// If a request is already in progress, this call is ignored.
    /// On success, the results replace the existing breed list.
    func requestBreeds() async {
        guard !isLoading else { return }

        breeds = await withLoadingState {
            await fetchDataFromStorageOrAPI()
        }
    }

    /// Sorts the breed list using the provided sorting type.
    /// - Parameter type: The sorting strategy to use.
    func sort(by type: BreedSortType) async {
        let sorted: [BreedViewModel] = await Task(priority: .userInitiated) { [weak self] in
            guard let self else { return [] }
            return self.breeds.sorted(by: type.comparator)
        }.value

        withAnimation(.bouncy) { breeds = sorted }
    }
}

// MARK: - DataFetcher implementation
extension BreedListViewModel: DataFetcher {
    typealias StoredData = Breed
    typealias APIData = BreedViewModel
    typealias ViewModel = BreedViewModel

    func fetchStoredData() async throws -> [StoredData] {
        try await storageReader.fetch(sortBy: SortDescriptor(\.name))
    }

    func fetchAPIData() async throws -> [APIData] {
        let breeds = try await breedService.requestBreeds()
        return breeds.map { BreedViewModel(breed: $0) }
    }

    func storeData(_ data: [StoredData]) async throws {
        try await storageReader.store(data)
    }

    func transformToViewModel(_ data: StoredData) -> ViewModel {
        ViewModel(breed: data)
    }

    func transformForStorage(_ data: ViewModel) -> StoredData {
        data.breed
    }
}

// MARK: - Private loading function
private extension BreedListViewModel {
    func withLoadingState<T>(_ operation: () async throws -> T) async rethrows -> T {
        isLoading = true
        defer { isLoading = false }
        return try await operation()
    }
}

// MARK: - Breed Sort Types
enum BreedSortType: String, CaseIterable, Identifiable {
    case name = "Name"
    case origin = "Origin"

    var id: String { rawValue }

    var comparator: (BreedViewModel, BreedViewModel) -> Bool {
        switch self {
        case .name:
            return { $0.name < $1.name }
        case .origin:
            return { $0.origin < $1.origin }
        }
    }
}
