import Foundation

/// A protocol defining the interface for fetching cat breed data.
protocol BreedServiceProtocol {
    /// Requests the list of cat breeds.
    ///
    /// - Returns: An array of `Breed` objects.
    /// - Throws: An error if the request or decoding fails.
    func requestBreeds() async throws -> [Breed]

    /// Requests images for a specific breed.
    ///
    /// - Parameters:
    ///   - breedID: The unique identifier for the breed.
    ///   - limit: The maximum number of images to fetch.
    /// - Returns: An array of image URLs.
    /// - Throws: An error if the request or decoding fails.
    func requestBreedImages(breedID: String, limit: Int) async throws -> [String]
}

// MARK: - BreedService implementation
/// A concrete implementation of `BreedServiceProtocol` for fetching cat breed data.
/// Currently loads data from local Mock JSON file. Will be updated to use TheCatAPI later.
final class BreedService {
    private let useMockData: Bool

    /// Creates a new `BreedService`.
    ///
    /// - Parameter useMockData: Whether to use mock data (default: true for Phase 1).
    init(useMockData: Bool = true) {
        self.useMockData = useMockData
    }
}

// MARK: - BreedServiceProtocol
extension BreedService: BreedServiceProtocol {
    /// Requests the list of cat breeds from mock data.
    ///
    /// - Returns: An array of `Breed` objects loaded from MockBreeds.json.
    /// - Throws: An error if the file cannot be found or decoded.
    func requestBreeds() async throws -> [Breed] {
        guard useMockData else {
            // TODO: Phase 3 - Implement real API call
            // return try await service.requestData(for: BreedRequest.breeds)
            throw BreedServiceError.apiNotImplemented
        }

        return try await loadMockBreeds()
    }

    /// Requests images for a specific breed.
    /// Currently returns placeholder URLs based on reference_image_id.
    ///
    /// - Parameters:
    ///   - breedID: The unique identifier for the breed.
    ///   - limit: The maximum number of images to fetch.
    /// - Returns: An array of image URLs from TheCatAPI CDN.
    func requestBreedImages(breedID: String, limit: Int = 5) async throws -> [String] {
        guard useMockData else {
            // TODO: Phase 3 - Implement real API call
            throw BreedServiceError.apiNotImplemented
        }

        // For mock data, return empty array (we'll use reference_image_id)
        return []
    }

    // MARK: - Private helpers

    /// Loads breed data from the bundled MockBreeds.json file.
    private func loadMockBreeds() async throws -> [Breed] {
        guard let url = Bundle.main.url(forResource: "MockBreeds", withExtension: "json") else {
            throw BreedServiceError.mockDataNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let breeds = try decoder.decode([Breed].self, from: data)

        return breeds
    }
}

// MARK: - Errors
enum BreedServiceError: LocalizedError {
    case mockDataNotFound
    case apiNotImplemented

    var errorDescription: String? {
        switch self {
        case .mockDataNotFound:
            return "Mock data file (MockBreeds.json) not found in bundle"
        case .apiNotImplemented:
            return "Real API integration not yet implemented. Coming in Phase 3!"
        }
    }
}
