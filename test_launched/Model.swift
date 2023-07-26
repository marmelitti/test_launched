//
//  Model.swift
//  test_launched
//
//  Created by Alexandra Brovko on 25/07/2023.
//

import Foundation

struct VendorsResponse: Decodable {
    let vendors: [Vendor]
}

struct Vendor: Decodable, Identifiable {
    let id: Int
    let companyName: String
    let areaServed: String
    let shopType: String
    let favorited: Bool
    let follow: Bool
    let businessType: String
    let coverPhoto: CoverPhoto?
    let categories: [Category]
    let tags: [Tag]
    
    private enum CodingKeys: String, CodingKey {
        case id, companyName = "company_name", areaServed = "area_served", shopType = "shop_type", favorited, follow, businessType = "business_type", coverPhoto = "cover_photo", categories, tags
    }
}

struct CoverPhoto: Codable {
    let id: Int
    let mediaURL: String
    let mediaType: String

    private enum CodingKeys: String, CodingKey {
        case id, mediaURL = "media_url", mediaType = "media_type"
    }
}

struct Category: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let image: CoverPhoto
}

struct Tag: Decodable, Hashable, Identifiable {
    let id: Int
    let name: String
    let purpose: String
}

extension Category {
    var imageUrl: String {
        return image.mediaURL
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.imageUrl == rhs.imageUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(imageUrl)
    }
}
