//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by LennartWisbar on 27.01.23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache retrieval")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return insertionError
    }

    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
        return deletionError
    }

    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch expectedResult {
            case .empty:
                guard case .empty = retrievedResult else {
                    XCTFail("Expected .empty, got \(retrievedResult) instead", file: file, line: line)
                    break
                }

            case .failure:
                guard case .failure = retrievedResult else {
                    XCTFail("Expected .failure, got \(retrievedResult) instead", file: file, line: line)
                    break
                }

            case let .found(expectedFeed, expectedTimestamp):
                guard case let .found(retrievedFeed, retrievedTimestamp) = retrievedResult else {
                    XCTFail("Expected \(expectedResult), got \(retrievedResult)", file: file, line: line)
                    break
                }
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }
}
