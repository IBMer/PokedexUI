//
//  BreedViewModel.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import SwiftUI

/// Protocol for Breed view models providing display-ready breed data.
protocol BreedViewModelProtocol {
    /// Unique breed identifier.
    var id: String { get }
    /// Display-ready breed name.
    var name: String { get }
    /// Origin country/region.
    var origin: String { get }
    /// Detailed description of the breed.
    var description: String { get }
    /// Temperament traits (comma-separated).
    var temperament: String { get }
    /// Life span range in years.
    var lifeSpan: String { get }
    /// Weight range (metric).
    var weightMetric: String { get }
    /// Weight range (imperial).
    var weightImperial: String { get }
    /// URL for the breed's reference image.
    var imageURL: String? { get }
    /// Additional image URLs for the breed.
    var imageURLs: [String] { get }
    /// Whether this breed is bookmarked.
    var isBookmarked: Bool { get set }

    /// Trait scores dictionary for easy access.
    var traits: [String: Int] { get }
}

// MARK: -
/// ViewModel providing formatted and display-ready data for a single cat breed.
struct BreedViewModel {
    private(set) var breed: Breed

    // MARK: - Public properties
    var isBookmarked: Bool

    /// Initializes the ViewModel with breed details.
    /// - Parameter breed: The breed model.
    init(breed: Breed) {
        self.breed = breed
        self.isBookmarked = breed.isBookmarked
    }
}

// MARK: - Calculated BreedViewModelProtocol properties
extension BreedViewModel: BreedViewModelProtocol {
    var id: String { breed.id }
    var name: String { breed.name }
    var origin: String { breed.origin }
    var description: String { breed.breedDescription }
    var temperament: String { breed.temperament }
    var lifeSpan: String { "\(breed.lifeSpan) years" }
    var weightMetric: String { "\(breed.weight.metric) kg" }
    var weightImperial: String { "\(breed.weight.imperial) lbs" }

    var imageURL: String? {
        if let referenceID = breed.referenceImageID {
            return "https://cdn2.thecatapi.com/images/\(referenceID).jpg"
        }
        return nil
    }

    var imageURLs: [String] {
        breed.imageURLs
    }

    var traits: [String: Int] {
        [
            "Adaptability": breed.adaptability,
            "Affection Level": breed.affectionLevel,
            "Child Friendly": breed.childFriendly,
            "Dog Friendly": breed.dogFriendly,
            "Energy Level": breed.energyLevel,
            "Grooming": breed.grooming,
            "Health Issues": breed.healthIssues,
            "Intelligence": breed.intelligence,
            "Shedding Level": breed.sheddingLevel,
            "Social Needs": breed.socialNeeds,
            "Stranger Friendly": breed.strangerFriendly,
            "Vocalisation": breed.vocalisation
        ]
    }
}

// MARK: - Equatable
extension BreedViewModel: Equatable {
    static func == (lhs: BreedViewModel, rhs: BreedViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Convenience computed properties
extension BreedViewModel {
    /// Returns a formatted string of temperament traits.
    var temperamentList: [String] {
        temperament.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// Returns the primary temperament trait.
    var primaryTrait: String {
        temperamentList.first ?? "Friendly"
    }

    /// Returns a summary for display in list views.
    var summary: String {
        "\(origin) • \(lifeSpan)"
    }
}
