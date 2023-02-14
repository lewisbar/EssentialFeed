//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 06.12.22.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
