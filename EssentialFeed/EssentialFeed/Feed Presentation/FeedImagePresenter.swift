//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 03.08.23.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location
        )
    }
}
