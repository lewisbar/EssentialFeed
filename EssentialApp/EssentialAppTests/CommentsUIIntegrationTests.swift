//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by LennartWisbar on 09.01.24.
//

import XCTest
import Combine
import UIKit
@testable import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    func test_commentsViewHasTitle() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()

        XCTAssertEqual(sut.title, commentsTitle)
    }

    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request when view appears")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request when user initiates load")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected a third loading request when user initiates load again")
    }

    func test_loadCommentsActions_runsAutomaticallyOnlyOnFirstAppearance() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no loading request the second time view appears")
    }

    override func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view appears")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    override func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading is completed")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiates a reload")

        loader.completeFeedLoading(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once user initiated reload is completed")
    }

    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)

        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        assertThat(sut, isRendering: [])

        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }

    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()

        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }

    override func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0], at: 0)

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }

    override func test_errorView_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        XCTAssertEqual(sut.errorMessage, nil)

        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    /*
     Deactivated because the test doesn't work with a label and a gesture recognizer instead of a button.
     The original project doesn't test this either. But I'll leave this here, as the button will return in a bonus lecture.
     This behavior was part of an exercise one had to implement on one's own. My solution used a button.
     I replaced it with a label now to be more aligned with the original project in order to avoid problems
     when following along.
     */
    //    func test_errorView_dismissesErrorMessageOnTap() {
    //        let (sut, loader) = makeSUT()
    //
    //        sut.simulateAppearance()
    //        XCTAssertEqual(sut.errorMessage, nil)
    //
    //        loader.completeFeedLoadingWithError(at: 0)
    //        XCTAssertEqual(sut.errorMessage, localized("GENERIC_CONNECTION_ERROR"))
    //
    //        sut.simulateTapOnErrorMessage()
    //        XCTAssertEqual(sut.errorMessage, nil)
    //    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }

    class LoaderSpy {
        private var requests = [PassthroughSubject<[FeedImage], Error>]()

        var loadCommentsCallCount: Int {
            requests.count
        }

        func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
            let publisher = PassthroughSubject<[FeedImage], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            requests[index].send(feed)
        }

        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
