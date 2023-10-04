//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 18.01.23.
//

import Foundation

enum FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let maxCachedAgeInDays = 7

    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCachedAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
