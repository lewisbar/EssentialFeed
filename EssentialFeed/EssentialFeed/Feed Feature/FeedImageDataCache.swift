//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 03.11.23.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
