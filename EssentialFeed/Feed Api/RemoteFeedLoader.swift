//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Srijan Bhatia on 04/08/22.
//

import Foundation

public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

final public class RemoteFeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init (url:URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Error) -> Void) {
		client.get(from: self.url) { error, response in
			if response != nil {
				completion(.invalidData)
			} else {
				completion(.connectivity)
			}
		}
	}
	
}
