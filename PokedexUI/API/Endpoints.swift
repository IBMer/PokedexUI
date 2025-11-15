import Networking

/// An enumeration for all the possible endpoints for TheCatAPI
enum Endpoint {
    case breeds
    case breedImages
}

// MARK: - EndpointType
extension Endpoint: EndpointType {
    var path: String {
        switch self {
            case .breeds: return "breeds"
            case .breedImages: return "images/search"
        }
    }
}
