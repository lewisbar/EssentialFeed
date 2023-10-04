//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by LennartWisbar on 29.07.23.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
