//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by LennartWisbar on 07.02.23.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache

    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        let managedImages = localFeed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            return managed
        }
        return NSOrderedSet(array: managedImages)
    }

    var local: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
