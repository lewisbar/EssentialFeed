//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by LennartWisbar on 16.01.23.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}
