//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by LennartWisbar on 29.07.23.
//

struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
