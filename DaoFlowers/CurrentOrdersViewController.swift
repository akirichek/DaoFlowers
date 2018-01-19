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
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterMarkLabel: UILabel!
    @IBOutlet weak var filterDateLabel: UILabel!

    var orders: [Order] = []
    var labels: [String] = []
    var dates: [Date] = []
    var labelsPickerView: UIPickerView!
    var datesPickerView: UIPickerView!
    var selectedLabel: String?
    var selectedDate: Date?
    var filteredOrders: [Date: [Order]] = [:]
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = CustomLocalisedString("Current Orders")
        filterMarkLabel.text = CustomLocalisedString("label").capitalized + ":"
        filterDateLabel.text = CustomLocalisedString("date").capitalized + ":"
        
        labelsPickerView = createPickerViewForTextField(labelTextField)
        datesPickerView = createPickerViewForTextField(dateTextField)
        fetchCurrentOrders(count: nil)
        
        var nib = UINib(nibName:"OrderTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CurrentOrderTableViewCellLandscapeIdentifier")
        
        nib = UINib(nibName:"DateTableViewHeader", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "DateTableViewHeaderIdentifier")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.tableView.reloadData()
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
        self.filteredOrders = Utils.filteredOrders(orders, byDate: selectedDate, byLabel: selectedLabel)
        self.tableView.reloadData()
    }
    
    func fetchCurrentOrders(count: Int?) {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchCurrentOrders(User.currentUser()!, count: count, completion: { orders, error in
            RBHUD.sharedInstance.hideLoader()
            if let orders = orders {
                self.orders = orders
                self.filteredOrders = Utils.filteredOrders(orders, byDate: nil, byLabel: nil)
                self.dates = Array(self.filteredOrders.keys)
                self.dates.sort(by: { $0 > $1 })
                self.tableView.reloadData()
            } else {
                Utils.showError(error!, inViewController: self)
            }
        })
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
        let alertController = UIAlertController(title: CustomLocalisedString("Filter"), message: CustomLocalisedString("Orders count:"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: CustomLocalisedString("Cancel"), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: CustomLocalisedString("OK"), style: .default) { (alertAction) in
            let ordersCount = alertController.textFields![0].text!
            self.fetchCurrentOrders(count: Int(ordersCount))
        }
        alertController.addTextField { (textField) in
            textField.placeholder = CustomLocalisedString("Type the number")
            textField.keyboardType = .decimalPad
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = dates[section]
        let ordersByDate = filteredOrders[date]!
        return ordersByDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String
        if self.isPortraitOrientation() {
            cellIdentifier = "CurrentOrderTableViewCellPortraitIdentifier"
        } else {
            cellIdentifier = "CurrentOrderTableViewCellLandscapeIdentifier"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderTableViewCell
        let date = dates[indexPath.section]
        let ordersByDate = filteredOrders[date]!
        cell.order = ordersByDate[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow = tableView.rowHeight
        
        if isPortraitOrientation() {
            let date = dates[indexPath.section]
            let ordersByDate = filteredOrders[date]!
            let order = ordersByDate[indexPath.row]
            let truckLabelWidth: CGFloat = 101
            let truckLabelHeight: CGFloat = 16
            let heightForText = Utils.heightForText(order.truck.name,
                                                    havingWidth: truckLabelWidth,
                                                    andFont: UIFont.systemFont(ofSize: 12))
            if heightForText > truckLabelHeight {
                heightForRow = 44 + (heightForText - truckLabelHeight)
            }
        } else {
            heightForRow = 36
        }
        
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.OrderDetails, sender: cell)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DateTableViewHeaderIdentifier")!
        let dateLabel = headerView.viewWithTag(1) as! UILabel
        let date = dates[section]
        let dateFormatter = DateFormatter()
        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold)
        let locale = Locale(identifier: LanguageManager.languageCode())
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "dd-MM-yyyy [EEEE]"
        dateLabel.text = dateFormatter.string(from: date as Date)
        
        return headerView
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
