//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 18.01.24.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
