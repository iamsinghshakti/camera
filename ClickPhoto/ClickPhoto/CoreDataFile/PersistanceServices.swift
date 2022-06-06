//
//  PersistanceServices.swift
//  ClickPhoto
//
//  Created by Shakti on 06/06/22.
//

import Foundation
import CoreData
class PersistenceService {
    
    private init(){}
    static let sharedIns = PersistenceService()
    var context:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ClickPhoto")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext (completion:@escaping(_ status:Bool)->Void) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {

                try context.save()
                completion(true)
            } catch {

                completion(false)
            }
        }
    }
    
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        let context = persistentContainer.viewContext
        let deleteBatchReq = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteBatchReq)
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
}
