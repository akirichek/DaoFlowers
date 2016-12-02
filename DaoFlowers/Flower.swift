//
//  Flower.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/14/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct Flower {
    var id: Int
    var name: String
    var abr: String?
    var imageUrl: String?
    var sortsCount: Int?
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        abr = dictionary["abr"] as? String
        imageUrl = dictionary["imgUrl"] as? String
        sortsCount = dictionary["sortsCount"] as? Int
    }
    
    struct Size {
        var id: Int
        var name: String
        
        init(dictionary: [String: AnyObject]) {
            id = dictionary["id"] as! Int
            name = dictionary["name"] as! String
        }
    }
    
    var defaultImage: String {
        var defaultImage = ""
        switch name.lowercaseString {
        case "agapanthus":
            defaultImage = "img_def_flower_agapanthus"
        case "alstromeria":
            defaultImage = "img_def_flower_alstro"
        case "":
            defaultImage = "img_def_flower_bq_exot"
        case "":
            defaultImage = "img_def_flower_bq_rond"
        case "callas":
            defaultImage = "img_def_flower_callas"
        case "carnations":
            defaultImage = "img_def_flower_carn"
        case "chrysants 1 bloom":
            defaultImage = "img_def_flower_chrysants_1_bloom"
        case "carnation mini-spray":
            defaultImage = "img_def_flower_chrysants_spray"
        case "":
            defaultImage = "img_def_flower_combo"
        case "":
            defaultImage = "img_def_flower_foliage"
        case "":
            defaultImage = "img_def_flower_gin"
        case "gypsophila":
            defaultImage = "img_def_flower_gypso"
        case "":
            defaultImage = "img_def_flower_helico"
        case "rose":
            defaultImage = "img_def_flower_rose"
        case "spray roses":
            defaultImage = "img_def_flower_spr_rose"
        default:
            defaultImage = "img_def_flower"
            break
        }
        
        return defaultImage
    }
}
