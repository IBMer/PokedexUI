//
//  BreedDetailView.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import SwiftUI
import SwiftData

struct BreedDetailView<ViewModel: BreedDetailViewModelProtocol & Sendable>: View {
    // MARK: - Environment Dependencies
    @Environment(\.imageColorAnalyzer) private var imageColorAnalyzer
    @Environment(\.spriteLoader) private var spriteLoader
    @Environment(\.modelContext) private var modelContext

    // MARK: - Data Query
    @Query(
        filter: #Predicate<Breed> { $0.isBookmarked },
        sort: \.name
    )
    private var bookmarks: [Breed]

    // MARK: - State Management
    @State private var viewModel: ViewModel

    // MARK: - Initialization
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Main Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                bannerSection()
                contentSection()
            }
        }
        .task(id: viewModel.breed.id) {
            await viewModel.loadImagesAndColor(
                withSpriteLoader: spriteLoader,
                imageColorAnalyzer: imageColorAnalyzer
            )
        }
        .onAppear {
            viewModel.updateBookmarkStatus(from: bookmarks)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                bookmarkButton
            }
        }
    }
}

// MARK: - Main Content Sections
private extension BreedDetailView {
    func bannerSection() -> some View {
        ZStack(alignment: .bottomTrailing) {
            bannerImage()

            // Gradient overlay for better text readability
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Breed name overlay
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.breed.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)

                Text(viewModel.breed.origin)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(height: 350)
    }

    func bannerImage() -> some View {
        Group {
            if let image = viewModel.mainImage {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Color.mewseumOrange.opacity(0.3)
                    ProgressView()
                        .tint(.orange)
                }
            }
        }
    }

    func contentSection() -> some View {
        VStack(spacing: 20) {
            basicInfoSection()
            temperamentSection()
            traitsSection()
            descriptionSection()
            apiAttributionSection()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Action Buttons
private extension BreedDetailView {
    var bookmarkButton: some View {
        Button {
            viewModel.toggleBookmark(in: modelContext)
        } label: {
            Image(systemName: viewModel.isBookmarked ? "heart.fill" : "heart")
                .font(.system(size: 20))
                .foregroundStyle(viewModel.isBookmarked ? .red : .primary)
        }
    }
}

// MARK: - Information Sections
private extension BreedDetailView {
    func basicInfoSection() -> some View {
        VStack(spacing: 12) {
            infoRow(icon: "globe.americas.fill", title: "Origin", value: viewModel.breed.origin)
            infoRow(icon: "calendar", title: "Life Span", value: viewModel.breed.lifeSpan)
            infoRow(icon: "scalemass", title: "Weight", value: viewModel.breed.weightMetric)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.mewseumOrange)
                .frame(width: 30)

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
        }
    }

    func temperamentSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Temperament")
                .font(.system(size: 20, weight: .bold))

            FlowLayout(spacing: 8) {
                ForEach(viewModel.breed.temperamentList, id: \.self) { trait in
                    Text(trait)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.mewseumOrange.opacity(0.2))
                        .foregroundStyle(Color.mewseumAccent)
                        .clipShape(Capsule())
                }
            }
        }
    }

    func traitsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Traits")
                .font(.system(size: 20, weight: .bold))

            VStack(spacing: 12) {
                traitRow(name: "Affection Level", value: viewModel.breed.traits["Affection Level"] ?? 0)
                traitRow(name: "Energy Level", value: viewModel.breed.traits["Energy Level"] ?? 0)
                traitRow(name: "Intelligence", value: viewModel.breed.traits["Intelligence"] ?? 0)
                traitRow(name: "Social Needs", value: viewModel.breed.traits["Social Needs"] ?? 0)
                traitRow(name: "Child Friendly", value: viewModel.breed.traits["Child Friendly"] ?? 0)
                traitRow(name: "Dog Friendly", value: viewModel.breed.traits["Dog Friendly"] ?? 0)
            }
        }
    }

    func traitRow(name: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(value)/5")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.mewseumOrange)
                        .frame(width: geometry.size.width * (CGFloat(value) / 5.0))
                }
            }
            .frame(height: 8)
        }
    }

    func descriptionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 20, weight: .bold))

            Text(viewModel.breed.description)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }

    func apiAttributionSection() -> some View {
        HStack {
            Spacer()

            VStack(spacing: 4) {
                Text("Powered by")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                Text("TheCatAPI")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.mewseumOrange)
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Flow Layout for Temperament Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var frames: [CGRect]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var frames: [CGRect] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.frames = frames
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BreedDetailView(viewModel: BreedDetailViewModel(breed: BreedViewModel(breed: .mockAbyssinian)))
    }
}
