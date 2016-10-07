//
//  RealmUtilities.swift
//  Mesh
//
//  Created by Christopher Truman on 9/28/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import RealmSwift

protocol Writable { }

extension Writable where Self: Object {
    func write(_ block: @escaping (Self) -> Void) {
        let realm = RealmUtilities.realm()
        try! realm.write { block(self) }
    }
    
    func delete() {
        let realm = RealmUtilities.realm()
        try! realm.write { realm.delete(self) }
    }
}

extension Object: Writable { }

struct RealmUtilities {
    
    static func objects<T:Object>(_ type: T.Type) -> [T] {
        let realm = RealmUtilities.realm()
        return Array(realm.objects(type));
    }
    
    static func realm() -> Realm {
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true
        return try! Realm(configuration: config)
    }
    
    static func deleteAll() {
        let realm = RealmUtilities.realm()
        try! realm.write { realm.deleteAll() }
    }
    
}
