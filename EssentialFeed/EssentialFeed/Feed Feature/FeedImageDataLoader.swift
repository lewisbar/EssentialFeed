//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by LennartWisbar on 21.04.23.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
