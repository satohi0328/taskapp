//
//  Category.swift
//  taskapp
//
//  Created by Hiroki Sato on 2020/06/07.
//  Copyright © 2020 hiroki.sato. All rights reserved.
//

import RealmSwift
class Category: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0

    // カテゴリ
    @objc dynamic var category = ""
    
    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
