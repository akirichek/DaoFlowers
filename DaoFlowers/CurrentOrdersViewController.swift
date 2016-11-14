//
//  CurrentOrdersViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/12/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class CurrentOrdersViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLandscapeView: UIView!
    @IBOutlet weak var headerPortraitView: UIView!
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var filterView: UIView!

    var orders: [Order] = []
    var filteredOrders: [Order] = []
    var labels: [String] = []
    var dates: [NSDate] = []
    var labelsPickerView: UIPickerView!
    var datesPickerView: UIPickerView!
    var selectedLabel: String?
    var selectedDate: NSDate?
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelsPickerView = createPickerViewForTextField(labelTextField)
        datesPickerView = createPickerViewForTextField(dateTextField)
        fetchCurrentOrders()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.adjustViewSize()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.tableView.reloadData()
        self.adjustViewSize()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let orderDetailsViewController = destinationViewController as? OrderDetailsViewController {
            let cell = sender as! OrderTableViewCell
            orderDetailsViewController.order = cell.order
        }
    }
    
    // MARK: - Private Methods
    
    func filterOrders() {
        var filteredOrders = orders
        if let selectedLabel = selectedLabel {
            filteredOrders = filteredOrders.filter({$0.clientLabel == selectedLabel})
        }
        if let selectedDate = selectedDate {
            filteredOrders = filteredOrders.filter({$0.headDate == selectedDate})
        }
        self.filteredOrders = filteredOrders
        self.tableView.reloadData()
    }
    
    func fetchCurrentOrders() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchCurrentOrders(User.currentUser()!, completion: { orders, error in
            RBHUD.sharedInstance.hideLoader()
            if let orders = orders {
                self.orders = orders
                self.filteredOrders = orders
                for order in orders {
                    if self.labels.indexOf(order.clientLabel) == nil {
                        self.labels.append(order.clientLabel)
                    }
                    if self.dates.indexOf(order.headDate) == nil {
                        self.dates.append(order.headDate)
                    }
                }
                self.tableView.reloadData()
            } else {
                Utils.showError(error!, inViewController: self)
            }
        })
    }
    
    func adjustViewSize() {
        var filterViewFrame = self.filterView.frame
        filterViewFrame.origin.y = self.contentViewFrame().origin.y
        self.filterView.frame = filterViewFrame
        
        var headerViewFrame: CGRect
        
        if isPortraitOrientation() {
            self.headerPortraitView.hidden = false
            self.headerLandscapeView.hidden = true
            headerViewFrame = self.headerPortraitView.frame
            headerViewFrame.origin.y = filterViewFrame.origin.y
            if !filterView.hidden {
                headerViewFrame.origin.y += filterViewFrame.height
            }
            self.headerPortraitView.frame = headerViewFrame
        } else {
            self.headerPortraitView.hidden = true
            self.headerLandscapeView.hidden = false
            headerViewFrame = self.headerLandscapeView.frame
            headerViewFrame.origin.y = filterViewFrame.origin.y
            if !filterView.hidden {
                headerViewFrame.origin.y += filterViewFrame.height
            }
            self.headerLandscapeView.frame = headerViewFrame
        }
        
        var tableViewFrame = self.tableView.frame
        tableViewFrame.origin.y = headerViewFrame.origin.y + headerViewFrame.size.height
        tableViewFrame.size.height = self.viewWillTransitionToSize.height - tableViewFrame.origin.y
        self.tableView.frame = tableViewFrame
    }
    
    func createPickerViewForTextField(textField: UITextField) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.inputView = pickerView
        return pickerView
    }
    
    // MARK: - Actions
    
    @IBAction func labelTextFieldClicked(sender: UITextField) {
        if let selectedLabel = selectedLabel {
            let row = self.labels.indexOf(selectedLabel)!
            self.labelsPickerView.selectRow(row + 1, inComponent: 0, animated: false)
        } else {
            self.labelsPickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func dateTextFieldClicked(sender: UITextField) {
        if let selectedDate = selectedDate {
            let row = self.dates.indexOf(selectedDate)!
            self.datesPickerView.selectRow(row + 1, inComponent: 0, animated: false)
        } else {
            self.datesPickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func filterButtonClicked(sender: UIBarButtonItem) {
        filterView.hidden = !filterView.hidden
        adjustViewSize()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOrders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier: String
        if self.isPortraitOrientation() {
            cellIdentifier = "CurrentOrderTableViewCellPortraitIdentifier"
        } else {
            cellIdentifier = "CurrentOrderTableViewCellLandscapeIdentifier"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! OrderTableViewCell
        cell.order = filteredOrders[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var heightForRow = tableView.rowHeight
        
        if isPortraitOrientation() {
            let order = filteredOrders[indexPath.row]
            let truckLabelWidth: CGFloat = 90
            let truckLabelHeight: CGFloat = 16
            let heightForText = Utils.heightForText(order.truck.name,
                                                    havingWidth: truckLabelWidth,
                                                    andFont: UIFont.systemFontOfSize(12))
            
            if heightForText > truckLabelHeight {
                heightForRow += heightForText - truckLabelHeight
            }
        }
        
        return heightForRow
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.OrderDetails, sender: cell)
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0
        if pickerView == labelsPickerView {
            numberOfRows = labels.count
        } else {
            numberOfRows = dates.count
        }
        
        return numberOfRows + 1
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var titleForRow: String
        if row == 0 {
            titleForRow = "--------"
        } else {
            if pickerView == labelsPickerView {
                titleForRow = labels[row - 1]
            } else {
                let date = dates[row - 1]
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                titleForRow = dateFormatter.stringFromDate(date)
            }
        }
        
        return titleForRow
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == labelsPickerView {
            self.labelTextField.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
            if row == 0 {
                self.selectedLabel = nil
            } else {
                self.selectedLabel = labels[row - 1]
            }
            self.labelTextField.resignFirstResponder()
        } else {
            self.dateTextField.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
            if row == 0 {
                self.selectedDate = nil
            } else {
                self.selectedDate = dates[row - 1]
            }
            self.dateTextField.resignFirstResponder()
        }
        
        if self.selectedLabel != nil || self.selectedDate != nil {
            self.filterButton.tintColor = UIColor(red: 237/255, green: 221/255, blue: 6/255, alpha: 1)
        } else {
            self.filterButton.tintColor = UIColor.whiteColor()
        }
        
        filterOrders()
    }
}
