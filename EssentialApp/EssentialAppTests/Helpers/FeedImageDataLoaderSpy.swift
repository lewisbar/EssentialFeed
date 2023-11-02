//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by LennartWisbar on 02.11.23.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
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
