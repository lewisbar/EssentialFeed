//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 05.01.23.
//

import Foundation

 struct RemoteFeedItem: Decodable {
     let id: UUID
     let description: String?
     let location: String?
     let image: URL
}
