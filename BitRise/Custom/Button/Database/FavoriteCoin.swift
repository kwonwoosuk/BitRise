//
//  FavoriteCoin.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import Foundation
import RealmSwift

class FavoriteCoin: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var dateAdded: Date
    
    convenience init(id: String, name: String) {
        self.init()
        self.id = id
        self.name = name
        self.dateAdded = Date()
    }
}
