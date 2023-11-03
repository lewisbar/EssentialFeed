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

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    func test_init_doesNotLoadImageData() {
        let loader = FeedImageDataLoaderSpy()
        _ = FeedImageDataLoaderCacheDecorator(decoratee: loader)

        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URLs on init")
    }

    func test_loadImageData_loadsURLFromLoader() {
        let url = anyURL()
        let (sut, loader) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(loader.loadedURLs, [url])
    }

    func test_cancelLoadImageData_cancelsTask() {
        let url = anyURL()
        let (sut, loader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()

        XCTAssertEqual(loader.cancelledURLs, [url])
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

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, decoratee: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)

        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)

        return (sut, loader)
    }
}
