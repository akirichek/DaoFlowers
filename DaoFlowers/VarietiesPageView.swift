//
//  VarietiesPageView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/20/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesPageView: UIView, UITableViewDataSource, UITableViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterContainerView: UIView!
    @IBOutlet weak var assortmentContainerView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var assortmentTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    
    var spinner = RBHUD()
    var delegate: VarietiesPageViewDelegate?
    var assortmentTypes: [VarietiesAssortmentType] = [.ByName, .ByPercentsOfPurchase, .BoughtLastMonth]
    var assortmentPickerView: UIPickerView!
    var state: VarietiesPageViewState!
    
    var filteredVarieties: [Variety]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Public Methods
    
    func reloadData() {
        if state.filter {
            showFilterContainerView()
        } else {
            hideFilterContainerView()
        }
        self.assortmentTextField.text = state.assortment.rawValue
        self.searchTextField.text = state.searchString
        self.tableView.contentOffset = CGPointZero
        self.filterVarieties()
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        let nib = UINib(nibName:"VarietyTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "VarietyTableViewCellIdentifier")
        assortmentContainerView.layer.cornerRadius = 5
        searchContainerView.layer.cornerRadius = 5
        self.assortmentPickerView = self.createPickerViewForTextField(self.assortmentTextField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.filteredVarieties == nil {
            self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func assortmentTextFieldClicked(sender: UITextField) {
        let row = self.assortmentTypes.indexOf(state.assortment)!
        self.assortmentPickerView.selectRow(row, inComponent: 0, animated: false)
    }
    
    // MARK: - Private Methods
    
    func createPickerViewForTextField(textField: UITextField) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(VarietiesPageView.doneButtonClicked(_:)))
        toolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        
        return pickerView
    }
    
    func showFilterContainerView() {
        filterContainerView.hidden = false
        tableViewTopConstraint.constant = 80
    }
    
    func hideFilterContainerView() {
        tableViewTopConstraint.constant = 0
        filterContainerView.hidden = true
    }
    
    func filterVarieties() {
        let term = state.searchString.lowercaseString
        if term.characters.count > 0 {
            if let varieties = state.varieties {
                let filteredVarienties = varieties.filter({$0.name.lowercaseString.containsString(term) || $0.abr.lowercaseString.containsString(term)})
                filteredVarieties = Utils.sortedVarieties(filteredVarienties, byAssortmentType: state.assortment)
            }
        } else {
            if let varieties = state.varieties {
                filteredVarieties = Utils.sortedVarieties(varieties, byAssortmentType: state.assortment)
            }
        }
    }
    
    // MARK: - Private Methods
    
    func doneButtonClicked(sender: UIBarButtonItem) {
        let selectedRow = self.assortmentPickerView.selectedRowInComponent(0)
        let assortmentType = self.assortmentTypes[selectedRow]
        self.assortmentTextField.text = assortmentType.rawValue
        self.assortmentTextField.resignFirstResponder()
        self.state.assortment = assortmentType
        if let filteredVarieties = self.filteredVarieties {
            self.filteredVarieties = Utils.sortedVarieties(filteredVarieties, byAssortmentType: assortmentType)
        }
        self.delegate?.varietiesPageView(self, didChangeState: state)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if let filteredVarieties = self.filteredVarieties {
            self.spinner.hideLoader()
            numberOfRows = filteredVarieties.count
        } else {
            self.setNeedsLayout()
        }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VarietyTableViewCellIdentifier",
                                                               forIndexPath: indexPath) as! VarietyTableViewCell
        cell.variety  = self.filteredVarieties![indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.delegate?.varietiesPageView(self, didSelectVariety: self.filteredVarieties![indexPath.row])
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return assortmentTypes.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let titleForRow = assortmentTypes[row].rawValue
        return titleForRow
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == searchTextField {
            var term = NSString(string: searchTextField.text!)
            term = term.stringByReplacingCharactersInRange(range, withString: string)
            state.searchString = term as String
            self.filterVarieties()
            self.delegate?.varietiesPageView(self, didChangeState: state)
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}

protocol VarietiesPageViewDelegate: NSObjectProtocol {
    func varietiesPageView(varietiesPageView: VarietiesPageView, didSelectVariety variety: Variety)
    func varietiesPageView(varietiesPageView: VarietiesPageView, didChangeState state: VarietiesPageViewState)
}

struct VarietiesPageViewState {
    var filter: Bool
    var assortment: VarietiesAssortmentType
    var searchString: String
    var varieties: [Variety]?
    var color: Color
    var index: Int
}