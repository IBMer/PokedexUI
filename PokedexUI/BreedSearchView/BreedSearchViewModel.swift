import Foundation
import SwiftData

/// A protocol defining the requirements for a ViewModel that handles breed search logic.
@MainActor
protocol BreedSearchViewModelProtocol {
    /// The filtered list of breeds based on the current query.
    var filtered: [BreedViewModel] { get }
    /// The user's search input query.
    var query: String { get set }

    /// Filters the breed list based on the query and updates `filteredBreeds`.
    func updateFilteredBreeds()

    init(breeds: [BreedViewModel])
}

// MARK: - BreedSearchViewModel
/// A ViewModel responsible for managing and filtering a list of cat breeds based on search queries.
@Observable
final class BreedSearchViewModel {
    // MARK: Private Properties
    /// The full list of breeds to be searched.
    private var breeds: [BreedViewModel]

    // MARK: - Public Properties
    /// The filtered breed data.
    var filtered: [BreedViewModel] = []

    /// The current search query entered by the user.
    var query: String = ""

    // MARK: - Init
    init(breeds: [BreedViewModel]) {
        self.breeds = breeds
    }
}

// MARK: - BreedSearchViewModelProtocol
extension BreedSearchViewModel: BreedSearchViewModelProtocol {
    /// Filters the internal breed list based on the current query.
    ///
    /// This method splits the query into normalized search terms (case- and diacritic-insensitive)
    /// and filters breeds whose name, origin, or temperament match all terms.
    func updateFilteredBreeds() {
        let queryTerms = query
            .split(whereSeparator: \.isWhitespace)
            .map { $0.normalize }
            .filter { !$0.isEmpty }

        guard !queryTerms.isEmpty else {
            filtered = []
            return
        }

        filtered = breeds.filter { breedVM in
            let name = breedVM.name.normalize
            let origin = breedVM.origin.normalize
            let temperament = breedVM.temperament.normalize

            return queryTerms.allSatisfy { term in
                name.contains(term) ||
                origin.contains(term) ||
                temperament.contains(term)
            }
        }
    }
}
