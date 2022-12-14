//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Srijan Bhatia on 07/08/22.
//

import Foundation

internal struct FeedItemsMapper {
	private struct Root: Decodable {
		let items: [Item]
		
		var feed: [FeedItem] {
			return items.map { $0.feedItem }
		}
	}

	private struct Item: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let image: URL
		
		var feedItem: FeedItem {
			return FeedItem(id: id, description: description, location: location, imageURL: image)
		}
	}
	private static var OK_200: Int {return 200}
	
	internal static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from:data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(root.feed)
	}
}
