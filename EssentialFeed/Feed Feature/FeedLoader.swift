//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Srijan Bhatia on 01/08/22.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
	associatedtype Error: Swift.Error
    func load(completion: @escaping(LoadFeedResult<Error>) -> Void)
}
