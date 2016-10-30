//
//  VarietiesPageView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/20/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesPageView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
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
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    
    var filteredVarieties: [Variety]? {
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
        self.assortmentTextField.text = state.assortment.rawValue
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
        collectionViewTopConstraint.constant = 80
    }
    
    func hideFilterContainerView() {
        collectionViewTopConstraint.constant = 0
        filterContainerView.hidden = true
    }
    
    func filterVarieties() {
        let term = state.searchString.lowercaseString
        var filteredVarieties = state.varieties
        if filteredVarieties != nil {
            if term.characters.count > 0 {
                filteredVarieties = filteredVarieties!.filter({$0.name.lowercaseString.containsString(term) || $0.abr.lowercaseString.containsString(term)})
            }
            filteredVarieties = Utils.sortedVarieties(filteredVarieties!, byAssortmentType: state.assortment)
        }
        
        self.filteredVarieties = filteredVarieties
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
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfRows = 0
        if let filteredVarieties = self.filteredVarieties {
            self.spinner.hideLoader()
            numberOfRows = filteredVarieties.count
        } else {
            self.setNeedsLayout()
        }
        return numberOfRows
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VarietyCollectionViewCellIdentifier", forIndexPath: indexPath) as! VarietyCollectionViewCell
        cell.variety  = self.filteredVarieties![indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.varietiesPageView(self, didSelectVariety: self.filteredVarieties![indexPath.row])
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