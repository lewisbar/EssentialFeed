//
//  FeedImageViewModelTests.swift
//  EssentialFeedTests
//
//  Created by LennartWisbar on 03.08.23.
//

import XCTest

final class FeedImageViewModelTests: XCTestCase {
    func test_hasLocation_returnsFalseIfLocationIsNil() {
        let sut = FeedImageViewModel<NSImage>(
            description: "a description",
            location: nil,
            image: nil,
            isLoading: false,
            shouldRetry: false
        )
    }

    func test_hasLocation_returnsTrueIfLocationIsNotNil() {
        let sut = FeedImageViewModel<NSImage>(
            description: "a description",
            location: "a location",
            image: nil,
            isLoading: false,
            shouldRetry: false
        )
    }
}
