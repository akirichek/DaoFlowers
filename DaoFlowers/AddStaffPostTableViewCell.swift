//
//  AddStaffPostTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 1/25/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class AddStaffPostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var post: Post! {
        didSet {
            nameLabel.text = post.name
        }
    }
}
