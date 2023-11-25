//
//  FeedImageViewModelTests.swift
//  EssentialFeedTests
//
//  Created by LennartWisbar on 03.08.23.
//

import XCTest
import EssentialFeed

final class FeedImageViewModelTests: XCTestCase {
    func test_hasLocation_returnsFalseIfLocationIsNil() {
        let sut = FeedImageViewModel(
            description: "a description",
            location: nil
        )
        XCTAssertEqual(sut.hasLocation, false)
    }

    func test_hasLocation_returnsTrueIfLocationIsNotNil() {
        let sut = FeedImageViewModel(
            description: "a description",
            location: "a location"
        )
        XCTAssertEqual(sut.hasLocation, true)
    }
}
