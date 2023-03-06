//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by LennartWisbar on 06.03.23.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }

    @objc func load() {
        loader?.load() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    func test_userInitiatedFeedLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    func test_viewDidLoad_showsLoadingIndicator() {
        func test_viewDidLoad_loadsFeed() {
            let (sut, _) = makeSUT()

            sut.loadViewIfNeeded()

            XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        }
    }

    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading()

        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }

    func test_userInitiatedFeedLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.simulateUserInitiatedFeedReload()

        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }

    func test_userInitiatedFeedLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading()

        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            completions.count
        }

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeFeedLoading() {
            completions[0](.success([]))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            let actions = actions(forTarget: target, forControlEvent: .valueChanged)

            actions?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
