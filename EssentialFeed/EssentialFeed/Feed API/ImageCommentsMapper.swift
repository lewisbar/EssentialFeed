//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 16.11.23.
//

import Foundation

final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    static var OK_200: Int { 200 }

    // Mapping from network to domain
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }

        return root.items
    }
}
