//
//  BreedModels.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import SwiftData
import Foundation

@Model
final class Breed: Decodable {
    @Attribute(.unique) var id: String
    var name: String
    var origin: String
    var breedDescription: String
    var temperament: String
    var lifeSpan: String
    var weight: WeightRange
    var referenceImageID: String?
    var imageURLs: [String] = []
    var isBookmarked: Bool = false

    // Trait scores (1-5 scale)
    var adaptability: Int
    var affectionLevel: Int
    var childFriendly: Int
    var dogFriendly: Int
    var energyLevel: Int
    var grooming: Int
    var healthIssues: Int
    var intelligence: Int
    var sheddingLevel: Int
    var socialNeeds: Int
    var strangerFriendly: Int
    var vocalisation: Int

    private enum CodingKeys: String, CodingKey {
        case id, name, origin, temperament, weight
        case breedDescription = "description"
        case lifeSpan = "life_span"
        case referenceImageID = "reference_image_id"
        case adaptability, intelligence, grooming
        case affectionLevel = "affection_level"
        case childFriendly = "child_friendly"
        case dogFriendly = "dog_friendly"
        case energyLevel = "energy_level"
        case healthIssues = "health_issues"
        case sheddingLevel = "shedding_level"
        case socialNeeds = "social_needs"
        case strangerFriendly = "stranger_friendly"
        case vocalisation
    }

    init(
        id: String,
        name: String,
        origin: String,
        breedDescription: String,
        temperament: String,
        lifeSpan: String,
        weight: WeightRange,
        referenceImageID: String? = nil,
        imageURLs: [String] = [],
        adaptability: Int = 0,
        affectionLevel: Int = 0,
        childFriendly: Int = 0,
        dogFriendly: Int = 0,
        energyLevel: Int = 0,
        grooming: Int = 0,
        healthIssues: Int = 0,
        intelligence: Int = 0,
        sheddingLevel: Int = 0,
        socialNeeds: Int = 0,
        strangerFriendly: Int = 0,
        vocalisation: Int = 0
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.breedDescription = breedDescription
        self.temperament = temperament
        self.lifeSpan = lifeSpan
        self.weight = weight
        self.referenceImageID = referenceImageID
        self.imageURLs = imageURLs
        self.adaptability = adaptability
        self.affectionLevel = affectionLevel
        self.childFriendly = childFriendly
        self.dogFriendly = dogFriendly
        self.energyLevel = energyLevel
        self.grooming = grooming
        self.healthIssues = healthIssues
        self.intelligence = intelligence
        self.sheddingLevel = sheddingLevel
        self.socialNeeds = socialNeeds
        self.strangerFriendly = strangerFriendly
        self.vocalisation = vocalisation
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        origin = try container.decode(String.self, forKey: .origin)
        breedDescription = try container.decode(String.self, forKey: .breedDescription)
        temperament = try container.decode(String.self, forKey: .temperament)
        lifeSpan = try container.decode(String.self, forKey: .lifeSpan)
        weight = try container.decode(WeightRange.self, forKey: .weight)
        referenceImageID = try container.decodeIfPresent(String.self, forKey: .referenceImageID)

        // Decode trait scores with defaults
        adaptability = try container.decodeIfPresent(Int.self, forKey: .adaptability) ?? 0
        affectionLevel = try container.decodeIfPresent(Int.self, forKey: .affectionLevel) ?? 0
        childFriendly = try container.decodeIfPresent(Int.self, forKey: .childFriendly) ?? 0
        dogFriendly = try container.decodeIfPresent(Int.self, forKey: .dogFriendly) ?? 0
        energyLevel = try container.decodeIfPresent(Int.self, forKey: .energyLevel) ?? 0
        grooming = try container.decodeIfPresent(Int.self, forKey: .grooming) ?? 0
        healthIssues = try container.decodeIfPresent(Int.self, forKey: .healthIssues) ?? 0
        intelligence = try container.decodeIfPresent(Int.self, forKey: .intelligence) ?? 0
        sheddingLevel = try container.decodeIfPresent(Int.self, forKey: .sheddingLevel) ?? 0
        socialNeeds = try container.decodeIfPresent(Int.self, forKey: .socialNeeds) ?? 0
        strangerFriendly = try container.decodeIfPresent(Int.self, forKey: .strangerFriendly) ?? 0
        vocalisation = try container.decodeIfPresent(Int.self, forKey: .vocalisation) ?? 0
    }
}

// MARK: - Mock Breed
extension Breed {
    static var mockAbyssinian: Breed {
        Breed(
            id: "abys",
            name: "Abyssinian",
            origin: "Egypt",
            breedDescription: "The Abyssinian is easy to care for, and a joy to have in your home. They're affectionate cats and love both people and other animals.",
            temperament: "Active, Energetic, Independent, Intelligent, Gentle",
            lifeSpan: "14 - 15",
            weight: WeightRange(imperial: "7 - 10", metric: "3 - 5"),
            referenceImageID: "0XYvRd7oD",
            adaptability: 5,
            affectionLevel: 5,
            energyLevel: 5, intelligence: 5
        )
    }
}

// MARK: - WeightRange Model
@Model
final class WeightRange: Codable {
    var imperial: String
    var metric: String

    enum CodingKeys: String, CodingKey {
        case imperial, metric
    }

    init(imperial: String, metric: String) {
        self.imperial = imperial
        self.metric = metric
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imperial = try container.decode(String.self, forKey: .imperial)
        metric = try container.decode(String.self, forKey: .metric)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imperial, forKey: .imperial)
        try container.encode(metric, forKey: .metric)
    }
}

// MARK: - Breed Image Response (for API)
struct BreedImageResponse: Codable {
    let id: String
    let url: String
    let width: Int
    let height: Int
}
