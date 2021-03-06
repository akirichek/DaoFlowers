//
//  UserProfileEmployeeTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 1/31/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class UserProfileEmployeeTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var customer: Customer!
    var employee: Employee!
    var emails: [String] = []
    var phonesMessengers: [Employee.Contact] = []
    var posts: [Post] = []
    var reports: [Report] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var nib = UINib(nibName: "UserProfileEmployeeContactTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "UserProfileEmployeeContactTableViewCellIdentifier")
        nib = UINib(nibName: "UserProfileEmployeePostsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "UserProfileEmployeePostsTableViewCellIdentifier")
    }
    
    func contentSizeBySettingEmployee(employee: Employee, customer: Customer) -> CGSize {
        self.employee = employee
        self.customer = customer
        emails = employee.emails()
        
        posts = customer.postsByIds(employee.postIds)
        reports = customer.reportsByIds(employee.reportIds)
        phonesMessengers = employee.phonesMessengers()
        tableView.reloadData()
        return tableView.contentSize
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch section {
        case 0:
            numberOfRows = emails.count
        case 1:
            numberOfRows = phonesMessengers.count
        case 2:
            numberOfRows = 1
        case 3:
            numberOfRows = 1
        default:
            break
        }
        return numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = nil
        
        var isLastRow = false
        let isFirstRow = (indexPath.row == 0)
        
        switch indexPath.section {
        case 0:
            cell = self.tableView(tableView, contactCellForRowAt: indexPath)
            isLastRow = (indexPath.row == emails.count - 1)
        case 1:
            cell = self.tableView(tableView, contactCellForRowAt: indexPath)
            isLastRow = (indexPath.row == phonesMessengers.count - 1)
        case 2:
            cell = self.tableView(tableView, postsAndReportsCellForRowAt: indexPath)
            isLastRow = true
        case 3:
            cell = self.tableView(tableView, postsAndReportsCellForRowAt: indexPath)
            isLastRow = true
        default:
            break
        }
        
        if isFirstRow && isLastRow {
            Utils.view(view: cell, byRoundingCorners: .allCorners)
        } else if isFirstRow {
            Utils.view(view: cell, byRoundingCorners: [.topLeft, .topRight])
        } else if isLastRow {
            Utils.view(view: cell, byRoundingCorners: [.bottomLeft, .bottomRight])
        } else {
            cell.layer.mask = nil
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, contactCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileEmployeeContactTableViewCellIdentifier", for: indexPath) as! UserProfileEmployeeContactTableViewCell
        switch indexPath.section {
        case 0:
            cell.email = emails[indexPath.row]
        case 1:
            cell.contact = phonesMessengers[indexPath.row]
        default:
            break
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          postsAndReportsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileEmployeePostsTableViewCellIdentifier", for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        switch indexPath.section {
        case 2:
            label.text = Utils.postsString(posts)
        case 3:
            label.text = Utils.reportsString(reports)
        default:
            break
        }
        return cell
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow: CGFloat = 0

        if indexPath.section == 2 || indexPath.section == 3 {
            var text = ""
            if indexPath.section == 2 {
                text = Utils.postsString(posts)
            } else if indexPath.section == 3 {
                text = Utils.reportsString(reports)
            }
            
            let heightForText = Utils.heightForText(text,
                                                    havingWidth: 280,
                                                    andFont: UIFont.systemFont(ofSize: 15))
            heightForRow = heightForText + 30
        } else {
            heightForRow = 44
        }
        
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        
        label.textAlignment = .center
        label.textColor = UIColor(red: 0/255, green: 103/255, blue: 196/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        switch section {
        case 0:
            label.text = CustomLocalisedString("Email")
        case 1:
            label.text = CustomLocalisedString("TelephoneMessengers")
        case 2:
            label.text = CustomLocalisedString("Post")
        case 3:
            label.text = CustomLocalisedString("Reports")
        default:
            break
        }
        
        return label
    }
}
