//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Srijan Bhatia on 12/08/22.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    private var session: HTTPSession
    init(withSession session: HTTPSession) {
        self.session = session
    }
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let task = self.session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
            
        }
        task.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(withSession: session)
        sut.get(from: url) { _ in }
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "any error", code: 0, userInfo: nil)
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(withSession: session)
        let expectation = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error: \(error) got result: \(result) instead")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private class HTTPSessionSpy: HTTPSession {
        private var stubbedTasks = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: NSError?
        }
        
        func stub(url: URL, task: HTTPSessionTask) {
            stubbedTasks[url] = Stub(task: task, error: nil)
        }
        
        func stub(url: URL, error: NSError) {
            stubbedTasks[url] = Stub(task: FakeURLSessionDataTask(), error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubbedTasks[url] else {
                fatalError("Couldn't find stub for given url")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() {
        }
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount: Int = 0
        func resume() {
            self.resumeCallCount += 1
        }
    }

}
