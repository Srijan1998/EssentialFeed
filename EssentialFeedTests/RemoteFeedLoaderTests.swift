//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Srijan Bhatia on 01/08/22.
//

import XCTest

class RemoteFeedLoader {
	let client: HTTPClient
	init (client: HTTPClient) {
		self.client = client
	}
	
	func load() {
		client.get(from: URL(string: "https://a-url.com")!)
	}
	
}

protocol HTTPClient {
	func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
	var requestedURL: URL?
	func get(from url: URL) {
		requestedURL = url
	}
}

class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotRequestDataFromUrl() {
		let client = HTTPClientSpy()
		_ = RemoteFeedLoader(client: client)
		
		XCTAssertNil(client.requestedURL)
	}
	
	func test_init_requestDataFromUrl() {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(client: client)
		
		sut.load()
		
		XCTAssertNotNil(client.requestedURL)
	}

}
