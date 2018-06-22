//
//  Category.swift
//  Todoey
//
//  Created by Ashley Donohoe on 6/21/18.
//  Copyright © 2018 Ashley Donohoe. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
