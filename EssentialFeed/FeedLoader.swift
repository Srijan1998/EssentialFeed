//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Srijan Bhatia on 01/08/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func loadItems(completion: @escaping(LoadFeedResult) -> Void)
}
