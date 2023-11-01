//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by LennartWisbar on 14.10.23.
//

import Foundation
import EssentialFeed

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}
