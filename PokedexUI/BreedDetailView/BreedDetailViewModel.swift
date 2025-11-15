import SwiftUI
import SwiftData

/// Protocol defining the requirements for a breed detail view model.
/// Provides state and behaviors for displaying and interacting with breed details in the UI.
@MainActor
protocol BreedDetailViewModelProtocol {
    /// The breed represented by this ViewModel.
    var breed: BreedViewModelProtocol { get }
    /// Indicates whether the breed is currently bookmarked by the user.
    var isBookmarked: Bool { get }
    /// The image for the breed's main photo, if loaded.
    var mainImage: Image? { get }
    /// Additional images for the breed gallery.
    var galleryImages: [Image] { get }
    /// The dominant color extracted from the breed's image, if available.
    var color: Color? { get }

    /// Loads the breed's images and determines the dominant color.
    /// - Parameters:
    ///   - spriteLoader: Helper for loading sprite images asynchronously.
    ///   - imageColorAnalyzer: Helper for extracting the dominant color from an image.
    func loadImagesAndColor(withSpriteLoader spriteLoader: SpriteLoader, imageColorAnalyzer: ImageColorAnalyzer) async
    /// Sets the `isBookmarked` property based on a provided list of bookmarked breeds.
    /// - Parameter bookmarks: Array of all bookmarked breeds from storage.
    func updateBookmarkStatus(from bookmarks: [Breed])
    /// Toggles the bookmark status for this breed in the provided model context.
    /// - Parameter context: The SwiftData model context.
    func toggleBookmark(in context: ModelContext)
}

/// Observable class that manages detailed UI state and behaviors for a single cat breed.
@Observable
final class BreedDetailViewModel {
    // MARK: Public Properties

    /// The breed to display details for.
    let breed: BreedViewModelProtocol
    /// Whether this breed is currently bookmarked.
    var isBookmarked = false
    /// The loaded main image.
    var mainImage: Image?
    /// Gallery images for the breed.
    var galleryImages: [Image] = []
    /// The dominant color extracted from the main image.
    var color: Color?

    // MARK: - Initialization
    /// Creates a new ViewModel for the specified breed.
    /// - Parameter breed: The breed to represent.
    init(breed: BreedViewModelProtocol) {
        self.breed = breed
        self.isBookmarked = breed.isBookmarked
    }
}

// MARK: - BreedDetailViewModelProtocol
extension BreedDetailViewModel: BreedDetailViewModelProtocol {
    /// Updates `isBookmarked` based on whether this breed appears in the provided bookmarks list.
    /// - Parameter bookmarks: The user's list of bookmarked breed entities.
    func updateBookmarkStatus(from bookmarks: [Breed]) {
        isBookmarked = bookmarks.contains(where: { $0.id == breed.id })
    }

    /// Loads the main image and extracts the dominant color.
    /// Updates the `mainImage`, `galleryImages`, and `color` properties.
    /// - Parameters:
    ///   - spriteLoader: Loader to fetch images asynchronously.
    ///   - imageColorAnalyzer: Analyzer to determine the dominant color from an image.
    func loadImagesAndColor(withSpriteLoader spriteLoader: SpriteLoader, imageColorAnalyzer: ImageColorAnalyzer) async {
        guard let imageURL = breed.imageURL,
              let image = await spriteLoader.spriteImage(from: imageURL)
        else { return }

        // Extract dominant color
        if let uicolor = await imageColorAnalyzer.dominantColor(for: breed.id, image: image) {
            color = Color(uiColor: uicolor)
        }

        mainImage = Image(uiImage: image)

        // Load gallery images (if available)
        for imageURL in breed.imageURLs {
            if let galleryImage = await spriteLoader.spriteImage(from: imageURL) {
                galleryImages.append(Image(uiImage: galleryImage))
            }
        }
    }

    /// Toggles the bookmark status for this breed in the specified model context and updates the view model state.
    /// - Parameter context: The SwiftData model context for persistence.
    func toggleBookmark(in context: ModelContext) {
        let id = breed.id
        let descriptor = FetchDescriptor<Breed>(predicate: #Predicate { $0.id == id })

        do {
            if let breedEntity = try context.fetch(descriptor).first {
                breedEntity.isBookmarked.toggle()
                isBookmarked = breedEntity.isBookmarked
                try context.save()
            }
        } catch {
            print("Failed to toggle bookmark: \(error)")
        }
    }
}
