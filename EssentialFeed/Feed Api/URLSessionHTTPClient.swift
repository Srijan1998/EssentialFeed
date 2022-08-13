//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Srijan Bhatia on 13/08/22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private var session: URLSession
    public init(withSession session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let task = self.session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
        task.resume()
    }
}
