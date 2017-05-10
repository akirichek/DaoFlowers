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
    @IBOutlet var dateLabels: [UILabel]!
    @IBOutlet var markLabels: [UILabel]!
    @IBOutlet var truckLabels: [UILabel]!
    @IBOutlet var pointLabels: [UILabel]!
    @IBOutlet var fbOrdLabels: [UILabel]!
    @IBOutlet var fbDiffLabels: [UILabel]!
    @IBOutlet weak var filterMarkLabel: UILabel!
    @IBOutlet weak var filterDateLabel: UILabel!

    var orders: [Order] = []
    var filteredOrders: [Order] = []
    var labels: [String] = []
    var dates: [Date] = []
    var labelsPickerView: UIPickerView!
    var datesPickerView: UIPickerView!
    var selectedLabel: String?
    var selectedDate: Date?
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = CustomLocalisedString("Current Orders")
        dateLabels.forEach { $0.text = CustomLocalisedString("date") }
        markLabels.forEach { $0.text = CustomLocalisedString("label") }
        truckLabels.forEach { $0.text = CustomLocalisedString("truck") }
        pointLabels.forEach { $0.text = CustomLocalisedString("point") }
        fbOrdLabels.forEach { $0.text = CustomLocalisedString("fb ord") }
        fbDiffLabels.forEach { $0.text = CustomLocalisedString("fb diff") }
        filterMarkLabel.text = CustomLocalisedString("label").capitalized + ":"
        filterDateLabel.text = CustomLocalisedString("date").capitalized + ":"
        
        labelsPickerView = createPickerViewForTextField(labelTextField)
        datesPickerView = createPickerViewForTextField(dateTextField)
        fetchCurrentOrders()
        
        let nib = UINib(nibName:"OrderTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CurrentOrderTableViewCellLandscapeIdentifier")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.adjustViewSize()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.tableView.reloadData()
        self.adjustViewSize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
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
            filteredOrders = filteredOrders.filter({$0.headDate as Date == selectedDate})
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
                    if self.labels.index(of: order.clientLabel) == nil {
                        self.labels.append(order.clientLabel)
                    }
                    if self.dates.index(of: order.headDate) == nil {
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
            self.headerPortraitView.isHidden = false
            self.headerLandscapeView.isHidden = true
            headerViewFrame = self.headerPortraitView.frame
            headerViewFrame.origin.y = filterViewFrame.origin.y
            if !filterView.isHidden {
                headerViewFrame.origin.y += filterViewFrame.height
            }
            self.headerPortraitView.frame = headerViewFrame
        } else {
            self.headerPortraitView.isHidden = true
            self.headerLandscapeView.isHidden = false
            self.headerLandscapeView.frame.size.width = self.view.frame.width
            headerViewFrame = self.headerLandscapeView.frame
            headerViewFrame.origin.y = filterViewFrame.origin.y
            if !filterView.isHidden {
                headerViewFrame.origin.y += filterViewFrame.height
            }
            self.headerLandscapeView.frame = headerViewFrame
        }
        
        var tableViewFrame = self.tableView.frame
        tableViewFrame.origin.y = headerViewFrame.origin.y + headerViewFrame.size.height
        tableViewFrame.size.height = self.viewWillTransitionToSize.height - tableViewFrame.origin.y
        self.tableView.frame = tableViewFrame
    }
    
    func createPickerViewForTextField(_ textField: UITextField) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.inputView = pickerView
        return pickerView
    }
    
    // MARK: - Actions
    
    @IBAction func labelTextFieldClicked(_ sender: UITextField) {
        if let selectedLabel = selectedLabel {
            let row = self.labels.index(of: selectedLabel)!
            self.labelsPickerView.selectRow(row + 1, inComponent: 0, animated: false)
        } else {
            self.labelsPickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func dateTextFieldClicked(_ sender: UITextField) {
        if let selectedDate = selectedDate {
            let row = self.dates.index(of: selectedDate)!
            self.datesPickerView.selectRow(row + 1, inComponent: 0, animated: false)
        } else {
            self.datesPickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func filterButtonClicked(_ sender: UIBarButtonItem) {
        filterView.isHidden = !filterView.isHidden
        adjustViewSize()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String
        if self.isPortraitOrientation() {
            cellIdentifier = "CurrentOrderTableViewCellPortraitIdentifier"
        } else {
            cellIdentifier = "CurrentOrderTableViewCellLandscapeIdentifier"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderTableViewCell
        cell.order = filteredOrders[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow = tableView.rowHeight
        
        if isPortraitOrientation() {
            let order = filteredOrders[indexPath.row]
            let truckLabelWidth: CGFloat = 90
            let truckLabelHeight: CGFloat = 16
            let heightForText = Utils.heightForText(order.truck.name,
                                                    havingWidth: truckLabelWidth,
                                                    andFont: UIFont.systemFont(ofSize: 12))
            if heightForText > truckLabelHeight {
                heightForRow += heightForText - truckLabelHeight
            }
        }
        
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.OrderDetails, sender: cell)
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0
        if pickerView == labelsPickerView {
            numberOfRows = labels.count
        } else {
            numberOfRows = dates.count
        }
        
        return numberOfRows + 1
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var titleForRow: String
        if row == 0 {
            titleForRow = "--------"
        } else {
            if pickerView == labelsPickerView {
                titleForRow = labels[row - 1]
            } else {
                let date = dates[row - 1]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                titleForRow = dateFormatter.string(from: date)
            }
        }
        
        return titleForRow
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
            self.filterButton.tintColor = UIColor.white
        }
        
        filterOrders()
    }
}
