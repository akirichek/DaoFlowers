//
//  UserProfileEmployeeContactTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 2/1/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class UserProfileEmployeeContactTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    
    var email: String! {
        didSet {
            valueLabel.text = email
            iconImageView.image = UIImage(named: "mail")
        }
    }
    
    var contact: Employee.Contact! {
        didSet {
            valueLabel.text = contact.value
            var icon = ""
            
            switch contact.type {
            case .mobile:
                fallthrough
            case .office:
                icon = "call"
            case .fax:
                icon = "fax"
            case .skype:
                icon = "skype"
            case .viber:
                icon = "viber"
            case .isq:
                icon = "isq"
            default:
                break
            }
            
            iconImageView.image = UIImage(named: icon)
        }
    }

}
