//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Srijan Bhatia on 01/08/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
