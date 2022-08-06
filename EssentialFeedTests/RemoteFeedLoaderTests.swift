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
		
		sut.load {_ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromUrl() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load {_ in }
		sut.load {_ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		expect(sut, toCompleteWithError: .connectivity) {
			let clientError = NSError.init(domain: "Error", code: 0)
			client.complete(with: clientError)
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		let samples = [199, 201, 300, 400, 500]
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWithError: .invalidData) {
				client.complete(withStatusCode: code, at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
		let (sut, client) = makeSUT()
		expect(sut, toCompleteWithError: .invalidData) {
			let invalidJsonData = Data("Invalid json".utf8)
			client.complete(withStatusCode: 200, withData: invalidJsonData)
		}
	}
	
	//MARK: -Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return (sut, client)
	}
	
	private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		var capturedErrors = [RemoteFeedLoader.Error]()
		sut.load { capturedErrors.append($0) }
		action()
		XCTAssertEqual(capturedErrors, [error], file: file, line: line)
	}
	
	private class HTTPClientSpy: HTTPClient {
		var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
		var requestedURLs: [URL] {
			return messages.map{ $0.url }
		}
		func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
			messages.append((url, completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func complete(withStatusCode code: Int, withData data: Data = Data(), at index: Int = 0) {
			let response = HTTPURLResponse(
				url: messages[index].url,
				statusCode: code,
				httpVersion: nil,
				headerFields: nil)!
			messages[index].completion(.success(data, response))
		}
	}

}
