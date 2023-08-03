//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by LennartWisbar on 03.08.23.
//

import XCTest
import AppKit
import EssentialFeed

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
    private let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false
        ))
    }

    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return // didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }

        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false
        ))
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendViewModel() {
        let (_, view) = makeSUT()

        XCTAssertEqual(view.messages, [])
    }

    func test_didStartLoadingImageData_sendsLoadingViewModel() {
        let (sut, view) = makeSUT()

        let model = FeedImage(id: UUID(), description: "a description", location: "a location", url: anyURL())

        sut.didStartLoadingImageData(for: model)

        XCTAssertEqual(view.messages, [FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false
        )])
    }

    func test_didFinishLoadingImageData_sendsImageViewModel() {
        let (sut, view) = makeSUT()

        let model = FeedImage(id: UUID(), description: "a description", location: "a location", url: anyURL())

        sut.didFinishLoadingImageData(with: anyImageData(), for: model)

        XCTAssertEqual(view.messages.count, 1)
        let message = view.messages[0]
        XCTAssertEqual(message.description, model.description)
        XCTAssertEqual(message.location, model.location)
        XCTAssertNotNil(message.image)
        XCTAssertEqual(message.isLoading, false)
        XCTAssertEqual(message.shouldRetry, false)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImagePresenter<ViewSpy, NSImage>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter<ViewSpy, NSImage>(view: view, imageTransformer: NSImage.init(data:))

        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, view)
    }

    private func anyImageData() -> Data {
        NSImage.make(withColor: .red).pngData()!
    }

    private class ViewSpy: FeedImageView {
        typealias Image = NSImage

        private(set) var messages = [FeedImageViewModel<Image>]()

        func display(_ model: FeedImageViewModel<Image>) {
            messages.append(model)
        }
    }
}

private extension NSImage {
    private static let smallSize = CGSize(width: 1, height: 1)

    static func make(withColor color: NSColor) -> NSImage {
        let size = smallSize
        let rect = NSRect(origin: .zero, size: size)
        var image = NSImage(size: size)
        image.lockFocus()
        color.drawSwatch(in: rect)
        image.unlockFocus()
        return image
    }

    func pngData(
        size: CGSize = smallSize,
        imageInterpolation: NSImageInterpolation = .high
    ) -> Data? {
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bitmapFormat: [],
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            return nil
        }

        bitmap.size = size
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        NSGraphicsContext.current?.imageInterpolation = imageInterpolation
        draw(
            in: NSRect(origin: .zero, size: size),
            from: .zero,
            operation: .copy,
            fraction: 1.0
        )
        NSGraphicsContext.restoreGraphicsState()

        return bitmap.representation(using: .png, properties: [:])
    }
}
