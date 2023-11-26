//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by LennartWisbar on 26.11.23.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)

        assertLocalizedKeysAndValuesExist(in: bundle, table)
    }
}
