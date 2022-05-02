//
//  ModelRealm.swift
//  RunMapGB
//
//  Created by emil kurbanov on 27.04.2022.
//

import Foundation
import RealmSwift



class ModelRealm: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    
}

