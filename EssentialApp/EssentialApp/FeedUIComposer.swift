//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by LennartWisbar on 02.05.23.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedUIComposer {
    private init() {}

    static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: { feedLoader().dispatchOnMainQueue() })

        let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: { imageLoader($0).dispatchOnMainQueue() }
            ),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController), 
            mapper: FeedPresenter.map
        )

        return feedController
    }

    private static func makeFeedViewController(delegate: ListViewControllerDelegate, title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
