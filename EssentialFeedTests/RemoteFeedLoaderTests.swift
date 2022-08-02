//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Srijan Bhatia on 01/08/22.
//

import XCTest

class RemoteFeedLoader {
	
	func load() {
		HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
	}
	
}

class HTTPClient {
	static var shared = HTTPClient()
	var requestedURL: URL?
	
	func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
	override func get(from url: URL) {
		requestedURL = url
	}
}

class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotRequestDataFromUrl() {
		let client = HTTPClientSpy()
		HTTPClient.shared = client
		_ = RemoteFeedLoader()
		
		XCTAssertNil(client.requestedURL)
	}
	
	func test_init_requestDataFromUrl() {
		let client = HTTPClientSpy()
		HTTPClient.shared = client
		let sut = RemoteFeedLoader()
		
		sut.load()
		
		XCTAssertNotNil(client.requestedURL)
	}

}
