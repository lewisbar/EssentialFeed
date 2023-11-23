//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by LennartWisbar on 05.07.23.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)

        assertLocalizedKeysAndValuesExist(in: bundle, table)
    }
}
