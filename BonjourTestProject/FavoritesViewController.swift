//
//  FavoritesViewController.swift
//  BonjourTestProject
//
//  Created by Ivan Grachev on 6/5/15.
//  Copyright (c) 2015 Ivan Grachev. All rights reserved.
//

import UIKit
import RealmSwift

class FavoritesViewController: StoredServicesViewController {

    override func fetchStoredServicesFunction() -> Results<StoredNetService>? {
        do {
            return try Realm().objects(StoredNetService).filter("favorited == true")
        }
        catch {}
        return nil
    }
    
}
