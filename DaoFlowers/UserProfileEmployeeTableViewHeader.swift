//
//  UserProfileEmployeeTableViewHeader.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 2/1/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class UserProfileEmployeeTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var nameLabel: UILabel!
    
    weak var delegate: UserProfileEmployeeTableViewHeaderDelegate?
    var section: Int!
    
    var employee: Employee! {
        didSet {
            nameLabel.text = employee.name
        }
    }

    @IBAction func editButtonClicked(_ sender: UIButton) {
        delegate?.userProfileEmployeeTableViewHeader(userProfileEmployeeTableViewHeader: self, editButtonClickedWithEmployee: employee)
    }

    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        delegate?.userProfileEmployeeTableViewHeader(userProfileEmployeeTableViewHeader: self, deleteButtonClickedWithEmployee: employee)
    }
}

protocol UserProfileEmployeeTableViewHeaderDelegate: NSObjectProtocol {
    func userProfileEmployeeTableViewHeader(userProfileEmployeeTableViewHeader: UserProfileEmployeeTableViewHeader, editButtonClickedWithEmployee employee: Employee)
    
    func userProfileEmployeeTableViewHeader(userProfileEmployeeTableViewHeader: UserProfileEmployeeTableViewHeader, deleteButtonClickedWithEmployee employee: Employee)
}
