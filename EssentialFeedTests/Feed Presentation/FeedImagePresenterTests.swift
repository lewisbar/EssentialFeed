//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by LennartWisbar on 03.08.23.
//

import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendViewModel() {
        let (_, view) = makeSUT()

        XCTAssertEqual(view.messages.count, 0)
    }

    func test_didStartLoadingImageData_sendsLoadingViewModel() {
        let (sut, view) = makeSUT()
        let model = FeedImage(id: UUID(), description: "a description", location: "a location", url: anyURL())

        sut.didStartLoadingImageData(for: model)

        XCTAssertEqual(view.messages.count, 1)
        let receivedModel = view.messages[0]
        XCTAssertEqual(receivedModel.description, model.description)
        XCTAssertEqual(receivedModel.location, model.location)
        XCTAssertNil(receivedModel.image)
        XCTAssertEqual(receivedModel.isLoading, true)
        XCTAssertEqual(receivedModel.shouldRetry, false)
    }

    func test_didFinishLoadingImageData_sendsImageViewModel() {
        let (sut, view) = makeSUT()
        let model = FeedImage(id: UUID(), description: "a description", location: "a location", url: anyURL())

        sut.didFinishLoadingImageData(with: TestImage.validImageData(), for: model)

        XCTAssertEqual(view.messages.count, 1)
        let message = view.messages[0]
        XCTAssertEqual(message.description, model.description)
        XCTAssertEqual(message.location, model.location)
        XCTAssertNotNil(message.image)
        XCTAssertEqual(message.isLoading, false)
        XCTAssertEqual(message.shouldRetry, false)
    }

    func test_didFinishLoadingImageDataWithError_sendsViewModelWithRetry() {
        let (sut, view) = makeSUT()
        let model = FeedImage(id: UUID(), description: "a description", location: "a location", url: anyURL())

        sut.didFinishLoadingImageData(with: anyNSError(), for: model)

        XCTAssertEqual(view.messages.count, 1)
        let receivedModel = view.messages[0]
        XCTAssertEqual(receivedModel.description, model.description)
        XCTAssertEqual(receivedModel.location, model.location)
        XCTAssertNil(receivedModel.image)
        XCTAssertEqual(receivedModel.isLoading, false)
        XCTAssertEqual(receivedModel.shouldRetry, true)
    }

    func test_didFinishLoadingImageDataWithInvalidData_sendsViewModelWithRetry() {
        let (sut, view) = makeSUT()
        let model = FeedImage(id: UUID(), description: "a description", location: "a location", url: anyURL())

        sut.didFinishLoadingImageData(with: TestImage.invalidImageData(), for: model)

        XCTAssertEqual(view.messages.count, 1)
        let receivedModel = view.messages[0]
        XCTAssertEqual(receivedModel.description, model.description)
        XCTAssertEqual(receivedModel.location, model.location)
        XCTAssertNil(receivedModel.image)
        XCTAssertEqual(receivedModel.isLoading, false)
        XCTAssertEqual(receivedModel.shouldRetry, true)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImagePresenter<ViewSpy, TestImage>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter<ViewSpy, TestImage>(view: view, imageTransformer: TestImage.init(data:))

        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, view)
    }

    private class ViewSpy: FeedImageView {
        typealias Image = TestImage

        private(set) var messages = [FeedImageViewModel<Image>]()

        func display(_ model: FeedImageViewModel<Image>) {
            messages.append(model)
        }
    }
}
