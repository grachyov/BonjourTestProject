//
//  StoredNetService.swift
//  BonjourTestProject
//
//  Created by Ivan Grachev on 6/8/15.
//  Copyright (c) 2015 Ivan Grachev. All rights reserved.
//

import Foundation
import RealmSwift

class StoredNetService: Object {
    dynamic var name = ""
    dynamic var domain = defaultDomain
    dynamic var type = defaultWebServiceType
    dynamic var address = ""
    dynamic var favorited = false
    dynamic var seen = false
    
    override static func primaryKey() -> String? {
        //now objects' names are unic
        return "name"
    }
}

extension NSNetService {
    convenience init(storedNetService: StoredNetService) {
        self.init(domain: storedNetService.domain, type: storedNetService.type, name: storedNetService.name)
    }
}

func storeServiceInDatabase(service: NSNetService?, isSeen: Bool?, isFavorited: Bool?) {
    if service == nil {
        return
    }
    
    let serviceToStore = StoredNetService()
    serviceToStore.name = service!.name
    serviceToStore.domain = service!.domain
    serviceToStore.type = service!.type
    
    if let oldVersion = storedServiceWithName(service!.name) {
        serviceToStore.seen = oldVersion.seen
        serviceToStore.favorited = oldVersion.favorited
    }
    
    if isSeen != nil {
        serviceToStore.seen = isSeen!
    }
    if isFavorited != nil {
        serviceToStore.favorited = isFavorited!
    }
    
    do {
        let realm = try Realm()
        try realm.write {
            realm.add(serviceToStore, update: true)
        }
    }
    catch {}
}

func storedServiceWithName(name: String?) -> StoredNetService? {
    if name == nil {
        return nil
    }
    
    do {
        return try Realm().objects(StoredNetService).filter("name == %@", name!).first
    }
    catch {}
    return nil
}

func storeServiceWithUserFilledName(name: String, address: String) {
    let serviceToStore = StoredNetService()
    if address.hasPrefix("http://") {
        serviceToStore.address = address
    }
    else {
        serviceToStore.address = "http://" + address
    }
    serviceToStore.domain = ""
    serviceToStore.type = ""
    if name == "" {
        serviceToStore.name = tryToFindNameInAddress(address)
    }
    else {
        serviceToStore.name = name
    }
    serviceToStore.favorited = true
    
    do {
        let realm = try Realm()
        try Realm().write {
            realm.add(serviceToStore, update: true)
        }
    }
    catch {}
}

func tryToFindNameInAddress(address: String) -> String {
    //TODO: implement url parsing
    return giveNewDefaultServiceName()
}

func giveNewDefaultServiceName() -> String {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let currentNumber = userDefaults.integerForKey("Unnamed devices counter")
    userDefaults.setInteger(currentNumber + 1, forKey: "Unnamed devices counter")
    return "Unnamed Device \(currentNumber)"
}