//
//  UserProfileStaffView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 1/23/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class UserProfileStaffView: UIView, UITableViewDataSource, UITableViewDelegate, UserProfileEmployeeTableViewHeaderDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    weak var delegate: UserProfileStaffViewDelegate?
    var employees: [Employee]! {
        didSet {
            existingEmployees = employees.filter { $0.action != .delete }
        }
    }
    var customer: Customer!
    var existingEmployees: [Employee] = []
    var lastContentOffset: CGFloat = 0
    var heightsForRow: [CGFloat] = []

    @IBAction func addButtonClicked(_ sender: UIButton) {
        delegate?.userProfileStaffViewAddButtonClicked(userProfileStaffView: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var nib = UINib(nibName: "UserProfileEmployeeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "UserProfileEmployeeTableViewCellIdentifier")
        nib = UINib(nibName:"UserProfileEmployeeTableViewHeader", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "UserProfileEmployeeTableViewHeaderIdentifier")
    }
    
    func reloadData() {
        heightsForRow = []
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return existingEmployees.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileEmployeeTableViewCellIdentifier", for: indexPath) as! UserProfileEmployeeTableViewCell
        
        let employeeTableViewContentSize = cell.contentSizeBySettingEmployee(employee: existingEmployees[indexPath.section],
                                                                             customer: customer)
//        if heightsForRow.count < existingEmployees.count {
//            heightsForRow.append(employeeTableViewContentSize.height)
//            if indexPath.section == existingEmployees.count - 1 {
//                tableView.reloadData()
//            }
//        }

        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.userProfileStaffView(userProfileStaffView: self, editButtonClickedAtSection: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let employee = existingEmployees[indexPath.section]
        var heightForRow: CGFloat = 0
        heightForRow += CGFloat((employee.emails().count * 44) + 40)
        heightForRow += CGFloat((employee.phonesMessengers().count * 44) + 40)
        
        let posts = customer.postsByIds(employee.postIds)
        let heightForPosts = Utils.heightForText(Utils.postsString(posts),
                                                havingWidth: 280,
                                                andFont: UIFont.systemFont(ofSize: 15))
        heightForRow += heightForPosts + 73

        let reports = customer.reportsByIds(employee.reportIds)
        let heightForReports = Utils.heightForText(Utils.reportsString(reports),
                                                   havingWidth: 280,
                                                   andFont: UIFont.systemFont(ofSize: 15))
        heightForRow += heightForReports + 73
        
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "UserProfileEmployeeTableViewHeaderIdentifier") as! UserProfileEmployeeTableViewHeader
        headerView.delegate = self
        headerView.employee = existingEmployees[section]
        headerView.section = section
        return headerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.bounds.height - 1) {
            if lastContentOffset > scrollView.contentOffset.y {
                if addButton.transform.a < 1 && self.addButton.layer.animationKeys() == nil {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.addButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                    })
                }
            } else if lastContentOffset < scrollView.contentOffset.y {
                if addButton.transform.a > 0.01 && self.addButton.layer.animationKeys() == nil{
                    UIView.animate(withDuration: 0.5, animations: {
                        self.addButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    })
                }
            }
        }
        
        lastContentOffset = scrollView.contentOffset.y
    }
    
    // MARK: - UserProfileEmployeeTableViewHeaderDelegate
    
    func userProfileEmployeeTableViewHeader(userProfileEmployeeTableViewHeader: UserProfileEmployeeTableViewHeader, editButtonClickedWithEmployee employee: Employee) {
        delegate?.userProfileStaffView(userProfileStaffView: self, editButtonClickedAtSection: userProfileEmployeeTableViewHeader.section)
    }
    
    func userProfileEmployeeTableViewHeader(userProfileEmployeeTableViewHeader: UserProfileEmployeeTableViewHeader, deleteButtonClickedWithEmployee employee: Employee) {
        delegate?.userProfileStaffView(userProfileStaffView: self, deleteButtonClickedAtSection: userProfileEmployeeTableViewHeader.section)
    }
}

protocol UserProfileStaffViewDelegate: NSObjectProtocol {
    func userProfileStaffViewAddButtonClicked(userProfileStaffView: UserProfileStaffView)
    func userProfileStaffView(userProfileStaffView: UserProfileStaffView, editButtonClickedAtSection section: Int)
    func userProfileStaffView(userProfileStaffView: UserProfileStaffView, deleteButtonClickedAtSection section: Int)
}
