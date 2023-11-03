//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by LennartWisbar on 02.11.23.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoaderSpy

    init(decoratee: FeedImageDataLoaderSpy) {
        self.decoratee = decoratee
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    func test_load_deliversImageDataOnLoaderSuccess() {
        let data = anyData()
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)

        let exp = expectation(description: "Wait for loading to complete")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch receivedResult {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, data)
            case .failure:
                XCTFail("Expected success, got \(receivedResult) instead")
            }
            exp.fulfill()
        }

        loader.complete(with: .success(data))
        
        wait(for: [exp], timeout: 1)
    }

    func test_load_deliversErrorOnLoaderFailure() {
        let error = anyNSError()
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)

        let exp = expectation(description: "Wait for loading to complete")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch receivedResult {
            case let .failure(receivedError):
                XCTAssertEqual(receivedError as NSError, error)
            case .success:
                XCTFail("Expected failure, got \(receivedResult) instead")
            }
            exp.fulfill()
        }

        loader.complete(with: .failure(error))

        wait(for: [exp], timeout: 1)
    }
}
