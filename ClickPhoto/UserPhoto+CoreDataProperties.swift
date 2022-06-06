//
//  UserPhoto+CoreDataProperties.swift
//  ClickPhoto
//
//  Created by Shakti on 06/06/22.
//
//

import Foundation
import CoreData


extension UserPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPhoto> {
        return NSFetchRequest<UserPhoto>(entityName: "UserPhoto")
    }

    @NSManaged public var photo: Data?

}

extension UserPhoto : Identifiable {

}
