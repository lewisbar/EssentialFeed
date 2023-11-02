//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 02.11.23.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
