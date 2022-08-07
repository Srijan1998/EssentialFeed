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
		expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.connectivity)) {
			let clientError = NSError.init(domain: "Error", code: 0)
			client.complete(with: clientError)
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		let samples = [199, 201, 300, 400, 500]
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.invalidData)) {
				let json = makeItemsJson([])
				client.complete(withStatusCode: code, withData: json, at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
		let (sut, client) = makeSUT()
		expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.invalidData)) {
			let invalidJsonData = Data("Invalid json".utf8)
			client.complete(withStatusCode: 200, withData: invalidJsonData)
		}
	}
	
	func test_load_deliversSucessOn200HTTPResponseWithEmptyItemsJson() {
		let (sut, client) = makeSUT()
		expect(sut, toCompleteWithResult: .success([])) {
			let emptyListJson = makeItemsJson([])
			client.complete(withStatusCode: 200, withData: emptyListJson)
		}
	}
	
	func test_load_deliversSucessOn200HTTPResponseWithItemsJson() {
		let (sut, client) = makeSUT()
		let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)
		let item2 = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "https://a-url.com")!)
		expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
			let json = makeItemsJson([item1.json, item2.json])
			client.complete(withStatusCode: 200, withData: json)
		}
	}
	
	func test_load_doesNotDeliverResultAfterSutInstanceHasBeenDeallocated() {
		let url = URL(string: "https://a-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
		var capturedResults = [RemoteFeedLoader.Result]()
		sut?.load { capturedResults.append($0) }
		sut = nil
		let emptyListJson = makeItemsJson([])
		client.complete(withStatusCode: 200, withData: emptyListJson)
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	//MARK: -Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		trackMemoryLeaks(sut, file: file, line: line)
		trackMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
		}
	}
	
	private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
		let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
		let json = [
			"id": item.id.uuidString,
			"description": item.description,
			"location": item.location,
			"image": item.imageURL.absoluteString
		].reduce(into: [String: Any]()) { accumaltedResult, result in
			if let value = result.value {
				accumaltedResult[result.key] = value
			}
		}
		return (item, json)
	}
	
	private func makeItemsJson(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return  try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let expectation = expectation(description: "Wait for load completion")
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
			
			case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			
			default:
				XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
			}
			expectation.fulfill()
		}
		action()
		wait(for: [expectation], timeout: 1.0)
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
		
		func complete(withStatusCode code: Int, withData data: Data, at index: Int = 0) {
			let response = HTTPURLResponse(
				url: messages[index].url,
				statusCode: code,
				httpVersion: nil,
				headerFields: nil)!
			messages[index].completion(.success(data, response))
		}
	}
}
