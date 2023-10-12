//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialAppTests
//
//  Created by LennartWisbar on 12.10.23.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader

    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        primary.loadImageData(from: url) { result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                _ = self.fallback.loadImageData(from: url, completion: completion)
            }
        }
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let primaryData = Data(count: 1)
        let fallbackData = Data(count: 2)
        let primaryLoader = LoaderStub(result: .success(primaryData))
        let fallbackLoader = LoaderStub(result: .success(fallbackData))
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        let exp = expectation(description: "Wait for loading to complete")

        _ = sut.loadImageData(from: URL(string: "http://any-url.com")!) { result in
            switch result {
            case let .success(receivedImageData):
                XCTAssertEqual(receivedImageData, primaryData)
            case .failure:
                XCTFail("Expected success, got \(result) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_loadImageData_deliversFallbackDataOnPrimaryLoaderFailure() {
        let fallbackData = Data(count: 2)
        let primaryLoader = LoaderStub(result: .failure(anyNSError()))
        let fallbackLoader = LoaderStub(result: .success(fallbackData))
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        let exp = expectation(description: "Wait for loading to complete")

        _ = sut.loadImageData(from: URL(string: "http://any-url.com")!) { result in
            switch result {
            case let .success(receivedImageData):
                XCTAssertEqual(receivedImageData, fallbackData)
            case .failure:
                XCTFail("Expected success, got \(result) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }

    private class LoaderStub: FeedImageDataLoader {
        private let result: FeedImageDataLoader.Result

        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            completion(result)
            return LoaderTask()
        }

        private class LoaderTask: FeedImageDataLoaderTask {
            func cancel() {

            }
        }
    }
}
