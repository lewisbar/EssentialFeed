//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 03.08.23.
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        return location != nil
    }

    public init(description: String?, location: String?) {
        self.description = description
        self.location = location
    }
}
