//
//  CoreData.swift
//  Mesh
//
//  Created by Christopher Truman on 9/11/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import CoreData

class CoreData {
    
    static let shared = CoreData()
    
    static var applicationDataPath: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1].appendingPathComponent("Data.sqlite")
    }()
    
    static var managedObjectModel = NSManagedObjectModel(contentsOf: MainBundle.url(forResource: "Data", withExtension: "momd")!)!
    
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do { try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: applicationDataPath, options: nil)
        } catch { reload() }
        return coordinator
    }()
    
    static var managedObjectContext: NSManagedObjectContext = {
        return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType).then {
            $0.persistentStoreCoordinator = persistentStoreCoordinator; $0.mergePolicy = NSOverwriteMergePolicy
        }
    }()
    
    static var backgroundContext: NSManagedObjectContext = {
        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType).then {
            $0.persistentStoreCoordinator = persistentStoreCoordinator; $0.mergePolicy = NSOverwriteMergePolicy
        }
    }()
    
    static func fetch(_ entity: AnyClass, sortKey: String? = nil, ascending: Bool = false, predicate: NSPredicate? = nil) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: String(describing: entity))
        if sortKey != nil { request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: ascending)] }
        if predicate != nil { request.predicate = predicate }
        do { return try CoreData.backgroundContext.fetch(request) } catch {}; return []
    }
    
    static func saveBackgroundContext() {
        guard backgroundContext.hasChanges else { return }
        do { try backgroundContext.save() }
        catch {
            // Replace this implementation with code to handle the error appropriately.
            NSLog("Unresolved error \(error)"); abort()
        }
    }
    
    static func saveContext() {
        guard managedObjectContext.hasChanges else { return }
        do { try managedObjectContext.save() }
        catch {
            // Replace this implementation with code to handle the error appropriately.
            NSLog("Unresolved error \(error)"); abort()
        }
    }
    
    static func reload() {
        DispatchQueue.global(qos: .background).async {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            do {
                try coordinator.destroyPersistentStore(at: applicationDataPath, ofType: NSSQLiteStoreType, options: nil)
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: applicationDataPath, options: nil)
            } catch {
                print(error)
            }
            persistentStoreCoordinator = coordinator
            
            managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType).then {
                $0.persistentStoreCoordinator = persistentStoreCoordinator; $0.mergePolicy = NSOverwriteMergePolicy
            }
            backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType).then {
                $0.persistentStoreCoordinator = persistentStoreCoordinator; $0.mergePolicy = NSOverwriteMergePolicy
            }
        }
    }
    
    static func delete() {
        DispatchQueue.global(qos: .background).async {
            do {
                for entity in ["User", "Card", "Connection", "Message"] {
                    let entity = NSFetchRequest(entityName: entity) as NSFetchRequest<User>
                    let delete = NSBatchDeleteRequest(fetchRequest: entity as! NSFetchRequest<NSFetchRequestResult>)
                    try managedObjectContext.execute(delete)
                }
            } catch { print (error) }
        }
    }

}
