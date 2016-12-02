//
//  VarietiesByPlantationPageView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/9/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesByPlantationPageView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterContainerView: UIView!
    @IBOutlet weak var assortmentContainerView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    
    weak var delegate: VarietiesByPlantationPageViewDelegate?
    var colorsPickerView: UIPickerView!
    var state: VarietiesByPlantationPageViewState!
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    
    var filteredVarieties: [Variety]! {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Public Methods
    
    func reloadData() {
        if state.filter {
            showFilterContainerView()
        } else {
            hideFilterContainerView()
        }
        self.searchTextField.text = state.searchString
        self.collectionView.contentOffset = CGPointZero
        self.filterVarieties()
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        let nib = UINib(nibName:"VarietyCollectionViewCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "VarietyCollectionViewCellIdentifier")
        assortmentContainerView.layer.cornerRadius = 5
        searchContainerView.layer.cornerRadius = 5
        self.colorsPickerView = self.createPickerViewForTextField(self.colorTextField)
    }
    
    // MARK: - Actions
    
    @IBAction func colorTextFieldClicked(sender: UITextField) {
        if let selectedColor = state.selectedColor {
            let row = self.state.colors.indexOf({$0.id == selectedColor.id})!
            self.colorsPickerView.selectRow(row + 1, inComponent: 0, animated: false)
        } else {
            self.colorsPickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    // MARK: - Private Methods
    
    func createPickerViewForTextField(textField: UITextField) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(VarietiesByPlantationPageView.doneButtonClicked(_:)))
        toolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        
        return pickerView
    }
    
    func showFilterContainerView() {
        filterContainerView.hidden = false
        var collectionViewFrame = self.collectionView.frame
        collectionViewFrame.origin.y = 50
        collectionViewFrame.size.height = self.frame.height - 50
        self.collectionView.frame = collectionViewFrame
    }
    
    func hideFilterContainerView() {
        filterContainerView.hidden = true
        var collectionViewFrame = self.collectionView.frame
        collectionViewFrame.origin.y = 0
        collectionViewFrame.size.height = self.frame.height
        self.collectionView.frame = collectionViewFrame
    }
    
    func filterVarieties() {
        let term = state.searchString.lowercaseString
        var filteredVarieties = state.varieties
        if filteredVarieties != nil {
            if term.characters.count > 0 {
                filteredVarieties = filteredVarieties!.filter({$0.name.lowercaseString.containsString(term) || $0.abr.lowercaseString.containsString(term)})
            }
            if let selectedColor = state.selectedColor {
                filteredVarieties = filteredVarieties!.filter({$0.color.id == selectedColor.id})
            }
            filteredVarieties = Utils.sortedVarietiesByPercentsOfPurchase(filteredVarieties!)
        }
        
        self.filteredVarieties = filteredVarieties
    }
    
    // MARK: - Private Methods
    
    func doneButtonClicked(sender: UIBarButtonItem) {
        changeColor()
    }
    
    func changeColor() {
        let selectedRow = self.colorsPickerView.selectedRowInComponent(0)
        if selectedRow == 0 {
            self.colorTextField.text = "all"
            self.state.selectedColor = nil
        } else {
            let selectedColor = state.colors[selectedRow - 1]
            self.colorTextField.text = selectedColor.name
            self.state.selectedColor = selectedColor
        }
        self.colorTextField.resignFirstResponder()
        self.filterVarieties()
        self.delegate?.varietiesByPlantationPageView(self, didChangeState: state)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredVarieties.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VarietyCollectionViewCellIdentifier", forIndexPath: indexPath) as! VarietyCollectionViewCell
        cell.variety  = self.filteredVarieties![indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.varietiesByPlantationPageView(self,
                                                     didSelectVariety: self.filteredVarieties![indexPath.row])
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize = self.viewWillTransitionToSize
        let columnCount: Int
        if screenSize.width < screenSize.height {
            columnCount = 1
        } else {
            columnCount = 2
        }
        
        let width = screenSize.width / CGFloat(columnCount)
        return CGSize(width: width, height: 60)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return state.colors.count + 1
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var titleForRow: String
        if row == 0 {
            titleForRow = "all"
        } else {
            titleForRow = state.colors[row - 1].name
        }
        
        return titleForRow
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeColor()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == searchTextField {
            var term = NSString(string: searchTextField.text!)
            term = term.stringByReplacingCharactersInRange(range, withString: string)
            state.searchString = term as String
            self.filterVarieties()
            self.delegate?.varietiesByPlantationPageView(self, didChangeState: state)
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

protocol VarietiesByPlantationPageViewDelegate: NSObjectProtocol {
    func varietiesByPlantationPageView(varietiesByPlantationPageView: VarietiesByPlantationPageView, didSelectVariety variety: Variety)
    func varietiesByPlantationPageView(varietiesByPlantationPageView: VarietiesByPlantationPageView, didChangeState state: VarietiesByPlantationPageViewState)
}

struct VarietiesByPlantationPageViewState {
    var filter: Bool
    var searchString: String
    var varieties: [Variety]?
    var selectedColor: Color?
    var colors: [Color]
    var index: Int
}