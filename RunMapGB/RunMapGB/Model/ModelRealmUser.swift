//
//  ModelRealmUser.swift
//  RunMapGB
//
//  Created by emil kurbanov on 02.05.2022.
//

import Foundation
import RealmSwift

class Users: Object {
    @objc dynamic var login: String = ""
    @objc dynamic var password: String = ""
    
    
    override static func primaryKey() -> String? {
        return "login"
    }
}

