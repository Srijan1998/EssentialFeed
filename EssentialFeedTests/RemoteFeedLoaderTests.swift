//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Srijan Bhatia on 01/08/22.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotRequestDataFromUrl() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_requestsDataFromUrl() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromUrl() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		var capturedError = [RemoteFeedLoader.Error]()
		sut.load { capturedError.append($0) }
		let clientError = NSError.init(domain: "Error", code: 0)
		client.complete(with: clientError)
		XCTAssertEqual(capturedError, [.Connectivity])
	}
	
	//MARK: -Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var messages = [(url: URL, completion: (Error) -> Void)]()
		var requestedURLs: [URL] {
			return messages.map{ $0.url }
		}
		func get(from url: URL, completion: @escaping (Error) -> Void) {
			messages.append((url, completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(error)
		}
	}

}
