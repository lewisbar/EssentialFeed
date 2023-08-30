//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by LennartWisbar on 05.07.23.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            let actions = actions(forTarget: target, forControlEvent: .valueChanged)
            
            actions?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
