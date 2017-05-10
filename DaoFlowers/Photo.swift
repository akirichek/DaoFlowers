//
//  Photo.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 4/23/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

struct Photo {
    var id: String?
    var url: String?
    var image: UIImage?
    var name: String?
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as? String
        url = dictionary["url"] as? String
    }
    
    init(url: String) {
        self.url = url
    }
    
    init(image: UIImage, name: String) {
        self.image = image
        self.name = name
    }
}
