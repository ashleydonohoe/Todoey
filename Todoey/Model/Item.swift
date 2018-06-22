//
//  Item.swift
//  Todoey
//
//  Created by Ashley Donohoe on 6/21/18.
//  Copyright © 2018 Ashley Donohoe. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    var parentcategory = LinkingObjects(fromType: Category.self, property: "items")
}
