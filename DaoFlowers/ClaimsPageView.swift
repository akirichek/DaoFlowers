//
//  ClaimsPageView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 4/12/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class ClaimsPageView: UIView, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var filterContainerView: UIView!
    @IBOutlet var fliterFieldsContainersViews: [UIView]!
    @IBOutlet weak var markingTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    
    var lastContentOffset: CGFloat = 0
    
    weak var delegate: ClaimsPageViewDelegate?
    var viewWillTransitionToSize = UIScreen.main.bounds.size
    var dates: [Date]?
    var invoicesMode: Bool = true
    var markingPickerView: UIPickerView!
    var statusPickerView: UIPickerView!
    var fromDatePicker: UIDatePicker!
    var toDatePicker: UIDatePicker!
    var users: [User] = []
    var statuses: [Claim.Status] = [.Confirmed, .NotConfirmed]
    var selectedUser: User?
    var selectedStatus: Claim.Status?
    var filteredClaims: [Date: [Claim]]?
    var filterViewAppears: Bool = false {
        didSet {
            if filterViewAppears {
                showFilterContainerView()
            } else {
                hideFilterContainerView()
            }
        }
    }
    
    var fromDate: Date! {
        didSet {
            fromDateTextField.text = self.dateToString(fromDate)
            fromDatePicker.date = fromDate
        }
    }
    var toDate: Date! {
        didSet {
            toDateTextField.text = self.dateToString(toDate)
            toDatePicker.date = toDate
        }
    }
    
    var claims: [Claim]? {
        didSet {
            filteredClaims = Utils.sortedClaims(claims!, filteredByUser: selectedUser, filteredByStatus: selectedStatus)
            sortDates()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var nib = UINib(nibName:"ClaimTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ClaimTableViewCellIdentifier")
        
        nib = UINib(nibName:"DateTableViewHeader", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "DateTableViewHeaderIdentifier")
        
        fliterFieldsContainersViews.forEach({ $0.layer.cornerRadius = 5 })
        
        markingPickerView = self.createPickerViewForTextField(self.markingTextField)
        statusPickerView = self.createPickerViewForTextField(self.statusTextField)
        fromDatePicker = self.createDatePickerForTextField(fromDateTextField)
        toDatePicker = self.createDatePickerForTextField(toDateTextField)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        delegate?.claimsPageViewDidAddButtonClicked(self)
    }
    
    // MARK: - Private Methods
    
    func sortDates() {
        dates = Array(filteredClaims!.keys)
        dates!.sort(by: { (obj1, obj2) -> Bool in
            return obj1.compare(obj2) == ComparisonResult.orderedDescending
        })
    }
    
    func isPortraitOrientation() -> Bool {
        return self.viewWillTransitionToSize.width < self.viewWillTransitionToSize.height
    }
    
    func createPickerViewForTextField(_ textField: UITextField) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: self,
                                         action: #selector(ClaimsPageView.doneButtonClicked(_:)))
        toolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        
        return pickerView
    }
    
    func createDatePickerForTextField(_ textField: UITextField) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        textField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: self,
                                         action: #selector(ClaimsPageView.doneDatePickerButtonClicked(_:)))
        toolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        
        return datePicker
    }
    
    func doneButtonClicked(_ sender: UIBarButtonItem) {
        let index = markingPickerView.selectedRow(inComponent: 0)
        if index == 0 {
            selectedUser = nil
        } else {
            selectedUser = users[index - 1]
        }
        
        filterClaims()
    }
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func doneDatePickerButtonClicked(_ sender: UIBarButtonItem) {
        let fromDate = fromDatePicker.date
        let toDate = toDatePicker.date
        fromDateTextField.text = self.dateToString(fromDate)
        toDateTextField.text = self.dateToString(toDate)
        fromDateTextField.resignFirstResponder()
        toDateTextField.resignFirstResponder()
        delegate?.claimsPageView(self, didSelectFromDate: fromDate, toDate: toDate)
    }
    
    func filterClaims() {
        filteredClaims = Utils.sortedClaims(claims!, filteredByUser: selectedUser, filteredByStatus: selectedStatus)
        sortDates()
        self.tableView.reloadData()
        markingTextField.resignFirstResponder()
        statusTextField.resignFirstResponder()
    }
    
    func showFilterContainerView() {
        var tableViewFrame = self.tableView.frame
        tableViewFrame.origin.y = 100
        tableViewFrame.size.height = self.frame.height - 100
        self.tableView.frame = tableViewFrame
        filterContainerView.isHidden = false
    }
    
    func hideFilterContainerView() {
        var tableViewFrame = self.tableView.frame
        tableViewFrame.origin.y = 0
        tableViewFrame.size.height = self.frame.height
        self.tableView.frame = tableViewFrame
        filterContainerView.isHidden = true
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfRows = 0
        if let dates = self.dates {
            numberOfRows = dates.count
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = dates![section]
        let claimsByDate = filteredClaims![date]!
        return claimsByDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClaimTableViewCellIdentifier", for: indexPath) as! ClaimTableViewCell
        let date = dates![indexPath.section]
        let claimsByDate = filteredClaims![date]!
        cell.claim = claimsByDate[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow = tableView.rowHeight
        
        let date = dates![indexPath.section]
        let claimsByDate = filteredClaims![date]!
        let claim = claimsByDate[indexPath.row]
        
        if isPortraitOrientation() {
            let labelWidth: CGFloat = 179
            let labelHeight: CGFloat = 34
            let heightForText = Utils.heightForText(claim.comment,
                                                    havingWidth: labelWidth,
                                                    andFont: UIFont.italicSystemFont(ofSize: 14))
            
            if heightForText > labelHeight {
                heightForRow += heightForText - labelHeight
            }
        }
        
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DateTableViewHeaderIdentifier")!
        let dateLabel = headerView.viewWithTag(1) as! UILabel
        let date = dates![section]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateLabel.text = dateFormatter.string(from: date)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let date = dates![indexPath.section]
        let claimsByDate = filteredClaims![date]!
        let claim = claimsByDate[indexPath.row]
        delegate?.claimsPageView(self, didSelectClaim: claim)
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
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0
        switch pickerView {
        case markingPickerView:
            numberOfRows = users.count
        case statusPickerView:
            numberOfRows = statuses.count
        default:
            break
        }
        return numberOfRows + 1
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var titleForRow = "--------"
        switch pickerView {
        case markingPickerView:
            if row > 0 {
                titleForRow = users[row - 1].name
            }
        case statusPickerView:
            if row > 0 {
                let status = statuses[row - 1]
                switch status {
                case .NotConfirmed:
                    titleForRow = "not confirmed"
                case .Confirmed:
                    titleForRow = "confirmed"
                default:
                    break
                }
            }
        default:
            break
        }

        return titleForRow
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case markingPickerView:
            if row == 0 {
                selectedUser = nil
                markingTextField.text = "--------"
            } else {
                selectedUser = users[row - 1]
                markingTextField.text = selectedUser?.name
            }
        case statusPickerView:
            if row == 0 {
                selectedStatus = nil
                statusTextField.text = "--------"
            } else {
                selectedStatus = statuses[row - 1]
                statusTextField.text = (selectedStatus == .Confirmed) ? "confirmed" : "not confirmed"
            }
        default:
            break
        }

        filterClaims()
    }
}

protocol ClaimsPageViewDelegate: NSObjectProtocol {
    func claimsPageViewDidAddButtonClicked(_ claimsPageView: ClaimsPageView)
    func claimsPageView(_ claimsPageView: ClaimsPageView, didSelectFromDate fromDate: Date, toDate: Date)
    func claimsPageView(_ claimsPageView: ClaimsPageView, didSelectClaim claim: Claim)
}
