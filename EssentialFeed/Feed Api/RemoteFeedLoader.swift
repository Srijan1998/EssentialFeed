//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Srijan Bhatia on 04/08/22.
//

import Foundation

final public class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = LoadFeedResult
	
	public init (url:URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: self.url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success(data, response):
				completion(FeedItemsMapper.map(data: data, response: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
}
