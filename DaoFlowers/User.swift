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
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(data, forKey: K.UserDefaultsKey.Login)
        userDefaults.synchronize()
    }
    
    func logOut() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(K.UserDefaultsKey.Login)
        userDefaults.synchronize()
    }
    
    static func currentUser() -> User? {
        var user: User?
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let data = userDefaults.objectForKey(K.UserDefaultsKey.Login) as? NSData {
           user =  NSKeyedUnarchiver.unarchiveObjectWithData(data) as? User
        }
        
        return user
    }
    
    // MARK: - NSCoding
    
    required init(coder aDecoder: NSCoder) {
        langId = aDecoder.decodeObjectForKey("langId") as! Int
        name = aDecoder.decodeObjectForKey("name") as! String
        roleId = aDecoder.decodeObjectForKey("roleId") as! Int
        token = aDecoder.decodeObjectForKey("token") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(langId, forKey: "langId")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(roleId, forKey: "roleId")
        aCoder.encodeObject(token, forKey: "token")
    }
}