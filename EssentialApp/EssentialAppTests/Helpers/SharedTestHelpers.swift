//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by LennartWisbar on 14.10.23.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
    }
