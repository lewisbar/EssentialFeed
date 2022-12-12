//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 12.12.22.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]

        var feed: [FeedItem] {
            items.map { $0.item }
        }
    }

    /// API specific struct to decode from data and map to FeedItem
    /// If we would instead decode to FeedItem directly, we would couple FeedItem to the specific API.
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static var OK_200: Int { 200 }

    // Mapping from network to domain
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }

        return .success(root.feed)
    }
}
