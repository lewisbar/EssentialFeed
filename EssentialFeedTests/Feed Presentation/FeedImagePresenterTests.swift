//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by LennartWisbar on 03.08.23.
//

import XCTest
import AppKit

protocol FeedImageView {
    associatedtype Image: Equatable
    func display(_ model: FeedImageViewModel<Image>)
}

struct FeedImageViewModel<Image: Equatable>: Equatable {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    let view: View

    init(view: View) {
        self.view = view
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendViewModel() {
        let (_, view) = makeSUT()

        XCTAssertEqual(view.messages, [])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImagePresenter<ViewSpy, NSImage>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter<ViewSpy, NSImage>(view: view)

        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, view)
    }

    private class ViewSpy: FeedImageView {
        typealias Image = NSImage

        private(set) var messages = [FeedImageViewModel<Image>]()

        func display(_ model: FeedImageViewModel<Image>) {
            messages.append(model)
        }
    }
}
