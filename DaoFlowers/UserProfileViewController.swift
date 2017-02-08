//
//  UserProfileViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 1/23/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class UserProfileViewController: BaseViewController, PageViewerDataSource, UserProfileStaffViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, AddStaffViewControllerDelegate, UserProfileMainParametersViewDelegate {

    @IBOutlet weak var pageViewerContainerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var selectedUserTextField: UITextField!
    
    var pageViewer: PageViewer!
    var selectedUser = User.currentUser()!
    var customer: Customer?
    var selectedEmployeeIndex: Int?
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameLabel.text = selectedUser.name
        self.pageViewerContainerView.frame = self.contentViewFrame()
        let pageViewer = Bundle.main.loadNibNamed("PageViewer", owner: self, options: nil)?.first as! PageViewer
        pageViewer.frame = self.pageViewerContainerView.bounds
        pageViewer.dataSource = self
        pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
        fetchCustomerWithLoader(true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewerContainerView.frame = self.contentViewFrame()
        self.pageViewer.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let addStaffViewController = destination as? AddStaffViewController {
            addStaffViewController.selectedUser = selectedUser
            addStaffViewController.delegate = self
            addStaffViewController.customer = customer
            if let index = selectedEmployeeIndex {
               addStaffViewController.employee = customer!.employees[index]
            }
        }
    }
    
    func fetchCustomerWithLoader(_ loader: Bool) {
        customer = nil
        if loader {
            RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
        ApiManager.fetchCustomerByUser(selectedUser, completion: { (customer, error) in
            if loader {
                RBHUD.sharedInstance.hideLoader()
            }
            if let error = error {
                Utils.showError(error, inViewController: self)
            } else {
                self.customer = customer
                if let page = self.pageViewer.pageAtIndex(0) as? UserProfileMainParametersView {
                    page.customer = self.customer
                    page.reloadData()
                }
                if let page = self.pageViewer.pageAtIndex(1) as? UserProfileStaffView {
                    page.employees = self.customer!.employees
                    page.reloadData()
                }
            }
        })
    }
    
    func saveCustomer() {
        if customer != nil {
            RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
            ApiManager.saveCustomer(customer: customer!, byUser: selectedUser, completion: { (customer, error) in
                RBHUD.sharedInstance.hideLoader()
            })
        }
    }
    
    func removeChanges() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.removeChangesWithUser(selectedUser, completion: { (error) in
            RBHUD.sharedInstance.hideLoader()
            self.fetchCustomerWithLoader(false)
        })
    }
    
    // MARK: - Actions
    
    @IBAction func selectUserButtonClicked(_ sender: UIButton) {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        var selectedRow: Int!
        if selectedUser.id == User.currentUser()!.id {
            selectedRow = 0
        } else {
            selectedRow = 1 + User.currentUser()!.slaves!.index(where: { (user) -> Bool in
                return user.id == selectedUser.id
            })!
        }
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        selectedUserTextField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: self,
                                         action: #selector(UserProfileViewController.userPickerDoneButtonClicked(sender:)))
        toolbar.setItems([doneButton], animated: true)
        selectedUserTextField.inputAccessoryView = toolbar
        selectedUserTextField.becomeFirstResponder()
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: CustomLocalisedString("Saving changes"),
                                                message: CustomLocalisedString("Save changes in user's profile?"),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: CustomLocalisedString("YES"), style: .default) { (action) in
            self.saveCustomer()
        }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: CustomLocalisedString("NO"), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: CustomLocalisedString("Cancel changes"),
                                                message: CustomLocalisedString("Cancel changes in user's profile?"),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: CustomLocalisedString("YES"), style: .default) { (action) in
            self.removeChanges()
        }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: CustomLocalisedString("NO"), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func userPickerDoneButtonClicked(sender: UIBarButtonItem) {
        selectedUserTextField.resignFirstResponder()
    }

    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(_ pageViewer: PageViewer) -> Int {
        return 2
    }
    
    func pageViewer(_ pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return [CustomLocalisedString("Main parameters"), CustomLocalisedString("Staff")][index]
    }
    
    func pageViewer(_ pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: UIView!
        switch index {
        case 0:
            pageView = Bundle.main.loadNibNamed("UserProfileMainParametersView", owner: self, options: nil)?.first as? UIView
        case 1:
            pageView = Bundle.main.loadNibNamed("UserProfileStaffView", owner: self, options: nil)?.first as? UIView
        default:
            break
        }
        
        if let userProfileMainParametersView = pageView as? UserProfileMainParametersView {
            if customer != nil && userProfileMainParametersView.customer == nil {
                userProfileMainParametersView.delegate = self
                userProfileMainParametersView.customer = customer
                userProfileMainParametersView.reloadData()
            }
        } else if let userProfileStaffView = pageView as? UserProfileStaffView {
            userProfileStaffView.delegate = self
            if let employees = customer?.employees {
                userProfileStaffView.employees = employees
            }
        }
        
        return pageView!
    }
    
    // MARK: - UserProfileStaffViewDelegate
    
    func userProfileStaffViewAddButtonClicked(userProfileStaffView: UserProfileStaffView) {
        selectedEmployeeIndex = nil
        performSegue(withIdentifier: K.Storyboard.SegueIdentifier.AddStaff, sender: self)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 1
        
        if let slaves = User.currentUser()!.slaves {
            numberOfRows += slaves.count
        }
        
        return numberOfRows
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel! = view as? UILabel
        
        if label == nil {
            label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
        }
        
        var user: User!
        if row == 0 {
            user = User.currentUser()!
        } else if let slaves = User.currentUser()!.slaves {
            user = slaves[row - 1]
        }
        
        label.text = user.name
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            selectedUser = User.currentUser()!
        } else if let slaves = User.currentUser()!.slaves {
            selectedUser = slaves[row - 1]
        }
        self.usernameLabel.text = selectedUser.name
        selectedUserTextField.resignFirstResponder()
        fetchCustomerWithLoader(true)
    }
    
    // MARK: - AddStaffViewControllerDelegate
    
    func addStaffViewController(addStaffViewController: AddStaffViewController, didAddNewEmployee employee: Employee) {
        customer?.employees.append(employee)
        if let page = self.pageViewer.pageAtIndex(1) as? UserProfileStaffView {
            page.employees = customer!.employees
            page.reloadData()
        }
    }
    
    func addStaffViewController(addStaffViewController: AddStaffViewController, didEditEmployee employee: Employee) {
        customer?.employees[selectedEmployeeIndex!] = employee
        if let page = self.pageViewer.pageAtIndex(1) as? UserProfileStaffView {
            page.employees = customer!.employees
            page.reloadData()
        }
    }
    
    func userProfileStaffView(userProfileStaffView: UserProfileStaffView, editButtonClickedAtSection section: Int) {
        selectedEmployeeIndex = section
        performSegue(withIdentifier: K.Storyboard.SegueIdentifier.AddStaff, sender: self)
    }
    
    func userProfileStaffView(userProfileStaffView: UserProfileStaffView, deleteButtonClickedAtSection section: Int) {
        let employee = self.customer!.employees[section]
        let message = String(format: CustomLocalisedString("Are you sure deleting employee"), employee.name)
        let alertController = UIAlertController(title: CustomLocalisedString("Deletion of employee"),
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: CustomLocalisedString("YES"), style: .default) { (action) in
            self.customer?.employees[section].action = .delete
            if let page = self.pageViewer.pageAtIndex(1) as? UserProfileStaffView {
                page.employees = self.customer!.employees
                page.reloadData()
            }
        }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: CustomLocalisedString("NO"), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UserProfileMainParametersViewDelegate
    
    func userProfileMainParametersView(userProfileMainParametersView: UserProfileMainParametersView, didChangedCustomer customer: Customer) {
        self.customer?.recoveryEmail = customer.recoveryEmail
        self.customer?.recoveryPhone = customer.recoveryPhone
        self.customer?.organization = customer.organization
        self.customer?.address = customer.address
        self.customer?.detailedAddress = customer.detailedAddress
        self.customer?.url = customer.url
    }
}
