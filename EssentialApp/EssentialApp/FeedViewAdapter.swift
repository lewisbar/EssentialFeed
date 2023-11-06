//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by LennartWisbar on 06.07.23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private var imageLoader: FeedImageDataLoader

    init(controller: FeedViewController? = nil, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)

            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)

            return view
        })
    }
}
