//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Srijan Bhatia on 04/08/22.
//

import Foundation

final public class RemoteFeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public enum Result: Equatable {
		case success([FeedItem])
		case failure(Error)
	}
	
	public init (url:URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: self.url) { result in
			switch result {
			case let .success(data, response):
				if let items = try? FeedItemsMapper.map(data, response) {
					completion(.success(items))
				} else {
					completion(.failure(.invalidData))
				}
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}
	
}
