//
//  NSManagedObjectContext + CoreData.swift
//  Private Files
//
//  Created by Egor on 14.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import Foundation
import CoreData


extension NSManagedObjectContext {
    
    private class PersistentContainer: NSPersistentContainer {
        static let shared = PersistentContainer(name: "Private_Files")
        
        override init(name: String, managedObjectModel model: NSManagedObjectModel) {
            super.init(name: name, managedObjectModel: model)
            
            loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Unresolved error \(error)")
                }
            }
        }
    }
    
    static var shared: NSManagedObjectContext {
        return PersistentContainer.shared.viewContext
    }
}
