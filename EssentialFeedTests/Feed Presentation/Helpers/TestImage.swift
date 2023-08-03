//
//  TestImage.swift
//  EssentialFeedTests
//
//  Created by LennartWisbar on 03.08.23.
//

import Foundation

struct TestImage: Equatable {
    let data: Data

    init?(data: Data) {
        guard
            let isValid = String(data: data, encoding: .utf8).flatMap(Bool.init),
            isValid
        else { return nil }

        self.data = data
    }

    static func validImageData() -> Data {
        Data("true".utf8)
    }

    static func invalidImageData() -> Data {
        Data()
    }
    }
