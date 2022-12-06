//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by LennartWisbar on 06.12.22.
//

import XCTest

class RemoteFeedLoader {
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }
}
