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

    private class TaskWrapper: FeedImageDataLoaderTask{
        var wrapped: FeedImageDataLoaderTask?

        func cancel() {
            wrapped?.cancel()
        }
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()

        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }

        return task
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()

        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }

    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        let _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [], "Expected to load no URL from fallback loader")
    }

    func test_loadImageData_loadsFallbackOnPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        let _ = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: .failure(anyNSError()))

        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
    }

    func test_loadImageData_deliversFailureOnFailureOfBothPrimaryAndFallbackLoader() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        let _ = sut.loadImageData(from: url) { _ in }

        primaryLoader.complete(with: .failure(anyNSError()))
        fallbackLoader.complete(with: .failure(anyNSError()))

        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
    }

    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()

        XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancel URL loading in primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs, [], "Expected no cancelled URLs in fallback loader")
    }

    func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: .failure(anyNSError()))
        task.cancel()

        XCTAssertEqual(primaryLoader.cancelledURLs, [], "Expected no cancelled URLs in primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancel URL loading in fallback loader")
    }

    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let sentData = anyData()
        let (sut, primaryLoader, _) = makeSUT()

        let _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch receivedResult {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, sentData)
            case .failure:
                XCTFail("Expected success, got \(receivedResult) instead")
            }
        }

        primaryLoader.complete(with: .success(sentData))
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, primary: LoaderSpy, fallback: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }

//    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) {
//        let exp = expectation(description: "Wait for loading to complete")
//
//        _ = sut.loadImageData(from: anyURL()) { receivedResult in
//            switch (receivedResult, expectedResult) {
//            case let (.success(receivedImageData), .success(expectedImageData)):
//                XCTAssertEqual(receivedImageData, expectedImageData)
//            case (.failure, .failure):
//                break
//            default:
//                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
//            }
//
//            exp.fulfill()
//        }
//
//        wait(for: [exp], timeout: 1)
//    }

    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }

    private func anyData() -> Data {
        Data("any data".utf8)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }

    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var cancelledURLs = [URL]()

        var loadedURLs: [URL] {
            messages.map(\.url)
        }

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task() { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }

        func complete(with result: FeedImageDataLoader.Result, at index: Int = 0) {
            messages[index].completion(result)
        }

        private struct Task: FeedImageDataLoaderTask {
            var callback: () -> Void

            func cancel() {
                callback()
            }
        }
    }
}
