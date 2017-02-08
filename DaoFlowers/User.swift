//
//  User.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    var langId: Int?
    var name: String
    var roleId: Int?
    var token: String!
    var id: Int?
    var slaves: [User]?
    var marking: String?
    
    init(dictionary: [String: AnyObject]) {
        langId = dictionary["langId"] as? Int
        name = dictionary["name"] as! String
        roleId = dictionary["roleId"] as? Int
        token = dictionary["token"] as? String
        id = dictionary["id"] as? Int
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
    
    func addSlave(slave: User) {
        if slaves == nil {
            slaves = []
        }
        slave.token = self.token
        slaves!.append(slave)
    }
    
    // MARK: - NSCoding
    
    required init(coder aDecoder: NSCoder) {
        langId = aDecoder.decodeObject(forKey: "langId") as? Int
        name = aDecoder.decodeObject(forKey: "name") as! String
        roleId = aDecoder.decodeObject(forKey: "roleId") as? Int
        token = aDecoder.decodeObject(forKey: "token") as? String
        id = aDecoder.decodeObject(forKey: "id") as? Int
        slaves = aDecoder.decodeObject(forKey: "slaves") as? [User]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(langId, forKey: "langId")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(roleId, forKey: "roleId")
        aCoder.encode(token, forKey: "token")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(slaves, forKey: "slaves")
    }

    override var description: String {
        var description = ""
        description += "langId: \(langId),\n"
        description += "name: \(name),\n"
        description += "roleId: \(roleId),\n"
        description += "token: \(token),\n"
        description += "id: \(id),\n"
        description += "slaves: \(slaves)\n"
        return description
    }
}
