//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 02.11.23.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
