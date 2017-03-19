//
//  AddStaffViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 1/23/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class AddStaffViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var textFieldContainerViews: [UIView]!
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var postContainerView: UIView!
    @IBOutlet weak var reportsLabel: UILabel!
    @IBOutlet weak var reportsContainerView: UIView!
    @IBOutlet weak var reportsTableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet var emailsTextFields: [UITextField]!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var officeTextField: UITextField!
    @IBOutlet weak var faxTextField: UITextField!
    @IBOutlet weak var viberTextField: UITextField!
    @IBOutlet weak var skypeTextField: UITextField!
    @IBOutlet weak var isqTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var telephoneMessengersLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var repostsLabel: UILabel!
    @IBOutlet weak var markingLabel: UILabel!
    @IBOutlet weak var markingLangLabel: UILabel!
    @IBOutlet weak var nameSurnameLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    weak var delegate: AddStaffViewControllerDelegate?
    var employee: Employee?
    var customer: Customer?
    var selectedUser: User!
    var posts: [Post] = []
    var reports: [Report] = []
    var selectedPosts: [Post] = []
    var selectedReports: [Report] = []
    var doNotSendReports: Bool = false
    var sendAllReports: Bool = false
    var isEditingMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        markingLangLabel.text = CustomLocalisedString("Marking")
        nameSurnameLabel.text = CustomLocalisedString("Name, surname")
        emailLabel.text = CustomLocalisedString("Email")
        telephoneMessengersLabel.text = CustomLocalisedString("TelephoneMessengers")
        postLabel.text = CustomLocalisedString("Post")
        reportsLabel.text = CustomLocalisedString("Reports")
        
        closeButton.setTitle(CustomLocalisedString("Close"), for: .normal)
        saveButton.setTitle(CustomLocalisedString("Save"), for: .normal)
        
        containerView.layer.cornerRadius = 5.0
        textFieldContainerViews.forEach { (containerView) in
            containerView.layer.cornerRadius = 5.0
        }
        postContainerView.layer.cornerRadius = 5.0
        reportsContainerView.layer.cornerRadius = 5.0
        
        var nib = UINib(nibName: "AddStaffPostTableViewCell", bundle: nil)
        postTableView.register(nib, forCellReuseIdentifier: "AddStaffPostTableViewCellIdentifier")
        nib = UINib(nibName: "AddStaffReportTableViewCell", bundle: nil)
        reportsTableView.register(nib, forCellReuseIdentifier: "AddStaffReportTableViewCellIdentifier")
        
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchEmployeesParamsWithUser(selectedUser, completion: { (posts, reports, error) in
            RBHUD.sharedInstance.hideLoader()
            if let error = error {
                Utils.showError(error, inViewController: self)
            } else {
                self.posts = posts!
                self.reports = reports!
                self.reloadViews()
            }
        })
        
        adjustTextFields()
        
        if employee == nil {
            employee = Employee()
            employee!.id = 0
            employee!.name = ""
            employee!.postIds = []
            employee!.contacts = []
            employee!.reportIds = []
            employee!.reportsMode = Employee.ReportsMode.defaultMode
        } else {
            isEditingMode = true
            populateView()
        }
        
        markingLabel.text = customer?.marking
    }
    
    // MARK: - Private Methods
    
    func populateView() {
        nameTextField.text = employee?.name
        
        for contact in employee!.contacts {
            switch contact.type {
            case .email:
                let emails = contact.value.components(separatedBy: ",")
                for i in 0..<emails.count {
                    if i < emailsTextFields.count {
                        emailsTextFields[i].text = emails[i]
                    }
                }
            case .mobile:
                mobileTextField.text = contact.value
            case .office:
                officeTextField.text = contact.value
            case .fax:
                faxTextField.text = contact.value
            case .skype:
                skypeTextField.text = contact.value
            case .viber:
                viberTextField.text = contact.value
            case .isq:
                isqTextField.text = contact.value
            }
        }
        
        if let customer = customer {
            selectedPosts = customer.postsByIds(employee!.postIds)
            selectedReports = customer.reportsByIds(employee!.reportIds)
        }
    }
    
    func reloadViews() {
        postTableView.reloadData()
        reportsTableView.reloadData()
        postTableView.frame.size.height = postTableView.contentSize.height
        postContainerView.frame.size.height = postTableView.frame.height
        reportsLabel.frame.origin.y = postContainerView.frame.origin.y + postContainerView.frame.height + 10
        reportsTableView.frame.size.height = reportsTableView.contentSize.height
        reportsContainerView.frame.size.height = reportsTableView.frame.height
        reportsContainerView.frame.origin.y = reportsLabel.frame.origin.y + reportsLabel.frame.height + 10
        scrollView.contentSize = CGSize(width: 0,
                                        height: reportsContainerView.frame.origin.y + reportsContainerView.frame.height + 15)
    }
    
    func adjustTextFields() {
        var toolbar = UIToolbar()
        toolbar.sizeToFit()
        var doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: mobileTextField,
                                         action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        mobileTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                     style: UIBarButtonItemStyle.done,
                                     target: officeTextField,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        officeTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                     style: UIBarButtonItemStyle.done,
                                     target: faxTextField,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        faxTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                     style: UIBarButtonItemStyle.done,
                                     target: viberTextField,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        viberTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                     style: UIBarButtonItemStyle.done,
                                     target: isqTextField,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        isqTextField.inputAccessoryView = toolbar
    }
    
    func buildContacts() -> [Employee.Contact] {
        var contacts: [Employee.Contact] = []
        
        var emails: [String] = []
        for i in 0..<emailsTextFields.count {
            let emailsTextField = emailsTextFields[i]
            if emailsTextField.text!.characters.count > 0 {
                emails.append(emailsTextField.text!)
            }
        }
        
        if emails.count > 0 {
            contacts.append(Employee.Contact(type: .email, value: emails.joined(separator: ",")))
        }
        
        if mobileTextField.text!.characters.count > 0 {
            contacts.append(Employee.Contact(type: .mobile, value: mobileTextField.text!))
        }
        if officeTextField.text!.characters.count > 0 {
            contacts.append(Employee.Contact(type: .office, value: officeTextField.text!))
        }
        if faxTextField.text!.characters.count > 0 {
            contacts.append(Employee.Contact(type: .fax, value: faxTextField.text!))
        }
        if skypeTextField.text!.characters.count > 0 {
            contacts.append(Employee.Contact(type: .skype, value: skypeTextField.text!))
        }
        if viberTextField.text!.characters.count > 0 {
            contacts.append(Employee.Contact(type: .viber, value: viberTextField.text!))
        }
        if isqTextField.text!.characters.count > 0 {
            contacts.append(Employee.Contact(type: .isq, value: isqTextField.text!))
        }
        
        return contacts
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        let name = nameTextField.text!
        if name.characters.count == 0 {
            Utils.showErrorWithMessage(CustomLocalisedString("Cannot save changes. Indicate employee and try again"), inViewController: self)
        } else if selectedPosts.count == 0 {
            Utils.showErrorWithMessage(CustomLocalisedString("Cannot save changes. Select at least one position and try again"), inViewController: self)
        } else {
            employee!.name = nameTextField.text!
            employee!.postIds = customer?.idsFromPosts(selectedPosts)
            
            if doNotSendReports {
                employee!.reportIds = []
            } else if sendAllReports {
                employee!.reportIds = customer?.idsFromReports(reports)
            } else {
                employee!.reportIds = customer?.idsFromReports(selectedReports)
            }
            
            employee!.contacts = buildContacts()
            self.presentingViewController?.dismiss(animated: true, completion: {
                if self.isEditingMode {
                    self.delegate?.addStaffViewController(addStaffViewController: self, didEditEmployee: self.employee!)
                } else {
                    self.delegate?.addStaffViewController(addStaffViewController: self, didAddNewEmployee: self.employee!)
                }
            })
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch tableView {
        case postTableView:
            numberOfRows = posts.count
        case reportsTableView:
            numberOfRows = reports.count + 2
        default:
            break
        }
        return numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = nil
        switch tableView {
        case postTableView:
            let postTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddStaffPostTableViewCellIdentifier", for: indexPath) as! AddStaffPostTableViewCell
            let post = posts[indexPath.row]
            postTableViewCell.post = post
            cell = postTableViewCell
            if selectedPosts.index(where: { $0.id == post.id }) == nil {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        case reportsTableView:
            let reportTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddStaffReportTableViewCellIdentifier", for: indexPath) as! AddStaffReportTableViewCell
            if indexPath.row == 0 {
                reportTableViewCell.doNotSendReports = true
                reportTableViewCell.accessoryType = doNotSendReports ? .checkmark : .none
                
            } else if indexPath.row == 1 {
                reportTableViewCell.sendAllReports = true
                reportTableViewCell.accessoryType = sendAllReports ? .checkmark : .none
            } else {
                let report = reports[indexPath.row - 2]
                let isCellActivated = (!doNotSendReports && !sendAllReports)
                reportTableViewCell.setReport(report: report, isActived: isCellActivated)
                if selectedReports.index(where: { $0.id == report.id }) == nil {
                    reportTableViewCell.accessoryType = .none
                } else {
                    reportTableViewCell.accessoryType = .checkmark
                }
            }
            cell = reportTableViewCell
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)!
        switch tableView {
        case postTableView:
            let post = posts[indexPath.row]
            if cell.accessoryType == .checkmark {
                let index = selectedPosts.index(where: { $0.id == post.id })!
                selectedPosts.remove(at: index)
            } else {
                selectedPosts.append(post)
            }
            postTableView.reloadData()
        case reportsTableView:
            if indexPath.row == 0 {
                if cell.accessoryType == .checkmark {
                    doNotSendReports = false
                } else {
                    doNotSendReports = !doNotSendReports
                    sendAllReports = !doNotSendReports
                }
            } else if indexPath.row == 1 {
                if cell.accessoryType == .checkmark {
                    sendAllReports = false
                } else {
                    sendAllReports = !sendAllReports
                    doNotSendReports = !sendAllReports
                }
            } else {
                if !doNotSendReports && !sendAllReports {
                    let report = reports[indexPath.row - 2]
                    if cell.accessoryType == .checkmark {
                        let index = selectedReports.index(where: { $0.id == report.id })!
                        selectedReports.remove(at: index)
                    } else {
                        selectedReports.append(report)
                    }
                }
            }

            reportsTableView.reloadData()
        default:
            break
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow: CGFloat = 44
        if tableView == reportsTableView && indexPath.row > 1 {
            let report = reports[indexPath.row - 2]
            let heightForText = Utils.heightForText(report.name,
                                                    havingWidth: 220,
                                                    andFont: UIFont.systemFont(ofSize: 15))
            if heightForText > 21 {
                heightForRow += heightForText - 21
            }
        } else if tableView == postTableView {
            let post = posts[indexPath.row]
            let heightForText = Utils.heightForText(post.name,
                                                    havingWidth: 260,
                                                    andFont: UIFont.systemFont(ofSize: 15))
            if heightForText > 21 {
                heightForRow += heightForText - 21
            }
        }
        
        return heightForRow
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

protocol AddStaffViewControllerDelegate: NSObjectProtocol {
    func addStaffViewController(addStaffViewController: AddStaffViewController, didAddNewEmployee employee: Employee)
    func addStaffViewController(addStaffViewController: AddStaffViewController, didEditEmployee employee: Employee)
}
