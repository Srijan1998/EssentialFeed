//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Srijan Bhatia on 01/08/22.
//

import XCTest

class RemoteFeedLoader {
	
	func load() {
		HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
	}
	
}

class HTTPClient {
	static let shared = HTTPClient()
	private init () {}
	var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotRequestDataFromUrl() {
		let client = HTTPClient.shared
		_ = RemoteFeedLoader()
		
		XCTAssertNil(client.requestedURL)
	}
	
	func test_init_requestDataFromUrl() {
		let client = HTTPClient.shared
		let sut = RemoteFeedLoader()
		
		sut.load()
		
		XCTAssertNotNil(client.requestedURL)
	}

}
