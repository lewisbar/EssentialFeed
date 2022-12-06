//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 06.12.22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping () -> Void)
}
