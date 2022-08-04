//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Srijan Bhatia on 04/08/22.
//

import Foundation

public protocol HTTPClient {
	func get(from url: URL)
}

final public class RemoteFeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public init (url:URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load() {
		client.get(from: self.url)
	}
	
}
