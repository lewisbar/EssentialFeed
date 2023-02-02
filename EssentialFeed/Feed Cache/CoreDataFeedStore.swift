//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 02.02.23.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
    public init() {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {}
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
}
