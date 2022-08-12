//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Srijan Bhatia on 12/08/22.
//

import XCTest

class URLSessionHTTPClient {
    private var session: URLSession
    init(withSession session: URLSession) {
        self.session = session
    }
    func get(from url: URL) {
        self.session.dataTask(with: url) { _, _, _ in
            
        }
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(withSession: session)
        sut.get(from: url)
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        
    }

}
