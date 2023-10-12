//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
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
        primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                _ = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let primaryData = Data(count: 1)
        let fallbackData = Data(count: 2)
        let sut = makeSUT(primaryResult: .success(primaryData), fallbackResult: .success(fallbackData))

        expect(sut, toCompleteWith: .success(primaryData))
    }

    func test_loadImageData_deliversFallbackDataOnPrimaryLoaderFailure() {
        let fallbackData = Data(count: 2)
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackData))

        expect(sut, toCompleteWith: .success(fallbackData))
    }

    // MARK: - Helpers

    private func makeSUT(primaryResult: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader {
        let primaryData = primaryResult
        let fallbackData = fallbackResult
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for loading to complete")

        _ = sut.loadImageData(from: URL(string: "http://any-url.com")!) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImageData), .success(expectedImageData)):
                XCTAssertEqual(receivedImageData, expectedImageData)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
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
