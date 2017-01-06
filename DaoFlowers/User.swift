//
//  User.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    var langId: Int
    var name: String
    var roleId: Int
    var token: String
    
    init(dictionary: [String: AnyObject]) {
        langId = dictionary["langId"] as! Int
        name = dictionary["name"] as! String
        roleId = dictionary["roleId"] as! Int
        token = dictionary["token"] as! String
        super.init()
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: K.UserDefaultsKey.Login)
        userDefaults.synchronize()
    }
    
    func logOut() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: K.UserDefaultsKey.Login)
        userDefaults.synchronize()
    }
    
    static func currentUser() -> User? {
        var user: User?
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.object(forKey: K.UserDefaultsKey.Login) as? Data {
           user =  NSKeyedUnarchiver.unarchiveObject(with: data) as? User
        }
        
        return user
    }
    
    // MARK: - NSCoding
    
    required init(coder aDecoder: NSCoder) {
        langId = aDecoder.decodeInteger(forKey: "langId")
        name = aDecoder.decodeObject(forKey: "name") as! String
        roleId = aDecoder.decodeInteger(forKey: "roleId")
        token = aDecoder.decodeObject(forKey: "token") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(langId, forKey: "langId")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(roleId, forKey: "roleId")
        aCoder.encode(token, forKey: "token")
    }
}
