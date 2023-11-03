//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by LennartWisbar on 02.11.23.
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoaderSpy
    private let cache: FeedImageDataCache

    init(decoratee: FeedImageDataLoaderSpy, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.save(data, for: url) { _ in }
            }
            completion(result)
        }
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    func test_init_doesNotLoadImageData() {
        let loader = FeedImageDataLoaderSpy()
        let cache = CacheSpy()
        _ = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)

        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URLs on init")
    }

    func test_loadImageData_loadsURLFromLoader() {
        let url = anyURL()
        let (sut, loader) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(loader.loadedURLs, [url], "Expected to load URL from loader")
    }

    func test_cancelLoadImageData_cancelsTask() {
        let url = anyURL()
        let (sut, loader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()

        XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel URL loading from loader")
    }

    func test_loadImageData_deliversImageDataOnLoaderSuccess() {
        let data = anyData()
        let (sut, loader) = makeSUT()

        expect(sut, toCompleteWith: .success(data), when: {
            loader.complete(with: .success(data))
        })
    }

    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let error = anyNSError()
        let (sut, loader) = makeSUT()

        expect(sut, toCompleteWith: .failure(error), when: {
            loader.complete(with: .failure(error))
        })
    }

    func test_loadImageData_cachesImageDataOnLoaderSuccess() {
        let data = anyData()
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)

        let _ = sut.loadImageData(from: anyURL()) { _ in }

        loader.complete(with: .success(data))

        XCTAssertEqual(cache.messages, [.save(data)], "Expected to cache loaded image data on success")
    }

    func test_loadImageData_doesNotCacheImageDataOnLoaderFailure() {
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)

        let _ = sut.loadImageData(from: anyURL()) { _ in }

        loader.complete(with: .failure(anyNSError()))

        XCTAssertTrue(cache.messages.isEmpty, "Expected cache to receive no messages if loader fails")
    }

    // MARK: - Helpers

    private func makeSUT(cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, decoratee: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)

        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(cache)
        trackForMemoryLeaks(sut)

        return (sut, loader)
    }

    private class CacheSpy: FeedImageDataCache {
        private(set) var messages = [Message]()

        enum Message: Equatable {
            case save(Data)
        }

        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data))
        }
    }
}
