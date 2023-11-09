//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by LennartWisbar on 07.11.23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class FeedSnapshotTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()

        sut.display(emptyFeed())

        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }

    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        record(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }

    func test_feedWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        record(snapshot: sut.snapshot(), named: "FEED_WITH_ERROR_MESSAGE")
    }

    // MARK: - Helpers

    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }

    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }

    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                description: "Who is like Him, the Lion and the Lamb, seated on the throne? Mountains bow down, every ocean roars to the Lord of hosts. Praise Adonai from the rising of the sun till the end of every day. Praise Adonai, all the nations of the earth, all the angels and the saints sing praise.",
                location: "All throughout creation\nIncluding the visible and the invisible world",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "I've scaled all the highest of mountains, and I've stood at the edge of their peaks, but I still couldn't see to the edge of Your love for me. I walked on the wildest of waters, and I've sunk to the depths of the sea, but I still couldn't fathom the depths of Your love for me. Canyons wide, oceans deep can't contain all Your love for me. No matter how high or far I reach, there's no end to Your love for me",
                location: "Mountains, canyons, and oceans",
                image: UIImage.make(withColor: .green)
            )
        ]
    }

    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }

        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appending(component: "snapshots", directoryHint: .isDirectory)
            .appending(component: "\(name).png", directoryHint: .notDirectory)

        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }

        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?

    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        )
    }

    func didRequestImage() {
        controller?.display(viewModel)
    }

    func didCancelImageRequest() {}
}
