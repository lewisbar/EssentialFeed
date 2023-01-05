//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 06.12.22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
