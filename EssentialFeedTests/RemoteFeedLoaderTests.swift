//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Srijan Bhatia on 01/08/22.
//

import XCTest

class RemoteFeedLoader {
	
}

class HTTPClient {
	var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func test_init_doesNotRequestDataFromUrl() {
		let client = HTTPClient()
		_ = RemoteFeedLoader()
		
		XCTAssertNil(client.requestedURL)
	}

}
