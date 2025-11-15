//
//  BreedRequest.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import Networking

/// An enum for requesting breed data from TheCatAPI
enum BreedRequest: Requestable {
    case breeds
    case images(breedID: String, limit: Int)

    var encoding: Request.Encoding { .query }
    var httpMethod: HTTP.Method { .get }

    var endpoint: EndpointType {
        switch self {
        case .breeds:
            return Endpoint.breeds
        case .images:
            return Endpoint.breedImages
        }
    }

    var parameters: HTTP.Parameters {
        switch self {
        case .breeds:
            return HTTP.Parameters()
        case .images(let breedID, let limit):
            return [
                "breed_ids": breedID,
                "limit": "\(limit)"
            ]
        }
    }
}
