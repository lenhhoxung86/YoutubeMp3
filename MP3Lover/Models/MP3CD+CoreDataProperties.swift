//
//  MP3CD+CoreDataProperties.swift
//  
//
//  Created by tien dh on 12/31/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MP3CD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MP3CD> {
        return NSFetchRequest<MP3CD>(entityName: "MP3CD");
    }

    @NSManaged public var mp3Description: String?
    @NSManaged public var mp3DirectLink: String?
    @NSManaged public var mp3LocalLink: String?
    @NSManaged public var mp3Title: String?

}
