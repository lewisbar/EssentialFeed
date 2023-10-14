//
//  XCTestCase+trackForMemoryLeaks.swift
//  EssentialAppTests
//
//  Created by LennartWisbar on 12.10.23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}