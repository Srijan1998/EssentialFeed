//
//  EssentialFeed.swift
//  EssentialFeed
//
//  Created by Srijan Bhatia on 01/08/22.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
