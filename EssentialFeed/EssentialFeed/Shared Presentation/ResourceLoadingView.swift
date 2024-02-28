//
//  ResourceLoadingView.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 23.11.23.
//

import Foundation

public protocol ResourceLoadingView: AnyObject {
    func display(_ viewModel: ResourceLoadingViewModel)
}
