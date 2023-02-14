//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 06.12.22.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
