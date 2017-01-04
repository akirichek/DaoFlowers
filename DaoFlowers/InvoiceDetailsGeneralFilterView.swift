//
//  InvoiceDetailsGeneralFilterView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/19/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsGeneralFilterView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var plantationTextField: UITextField!
    @IBOutlet weak var flowerTextField: UITextField!
    @IBOutlet weak var varietyTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var awbTextField: UITextField!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!

    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size {
        didSet {
            adjustView()
        }
    }
    weak var delegate: InvoiceDetailsGeneralFilterViewDelegate?
    
    var countryPickerView: UIPickerView!
    var plantationPickerView: UIPickerView!
    var flowerPickerView: UIPickerView!
    var varietyPickerView: UIPickerView!
    var sizePickerView: UIPickerView!
    var awbPickerView: UIPickerView!
    
    var countries: [Country]!
    var plantations: [Plantation]!
    var flowers: [Flower]!
    var varieties: [Variety]!
    var sizes: [Flower.Size]!
    var awbs: [String]!
    
    var state: InvoiceDetailsGeneralFilterViewState! {
        didSet {
            populateView()
        }
    }
    
    var invoiceDetails: InvoiceDetails! {
        didSet {
            countries = invoiceDetails.countries
            plantations = Utils.sortedPlantationsByName(invoiceDetails.plantations)
            flowers = Utils.sortedFlowersByName(invoiceDetails.flowers)
            varieties = Utils.sortedVarietiesByName(invoiceDetails.varieties)
            sizes = Utils.sortedFlowerSizesByName(invoiceDetails.flowerSizes)
            
            awbs = []
            for head in invoiceDetails.heads {
                if !awbs.contains(head.awb) {
                    awbs.append(head.awb)
                }
            }
            awbs.sortInPlace { $0 < $1 }
        }
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()        

        countryPickerView = createPickerViewForTextField(countryTextField)
        plantationPickerView = createPickerViewForTextField(plantationTextField)
        flowerPickerView = createPickerViewForTextField(flowerTextField)
        varietyPickerView = createPickerViewForTextField(varietyTextField)
        sizePickerView = createPickerViewForTextField(sizeTextField)
        awbPickerView = createPickerViewForTextField(awbTextField)
    }
    
    // MARK: - Private Methods
    
    func populateView() {
        if let selectedCountry = state.selectedCountry {
            countryTextField.text = selectedCountry.name
        } else {
            countryTextField.text = "---------"
        }
        
        if let selectedPlantation = state.selectedPlantation {
            plantationTextField.text = selectedPlantation.name
        } else {
            plantationTextField.text = "---------"
        }
        
        if let selectedFlower = state.selectedFlower {
            flowerTextField.text = selectedFlower.name
        } else {
            flowerTextField.text = "---------"
        }
        
        if let selectedVariety = state.selectedVariety {
            varietyTextField.text = selectedVariety.name
        } else {
            varietyTextField.text = "---------"
        }
        
        if let selectedSize = state.selectedSize {
            sizeTextField.text = selectedSize.name
        } else {
            sizeTextField.text = "---------"
        }
        
        if let selectedAwb = state.selectedAwb {
            awbTextField.text = selectedAwb
        } else {
            awbTextField.text = "---------"
        }
    }
    
    func createPickerViewForTextField(textField: UITextField) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.inputView = pickerView
        
        return pickerView
    }
    
    func resignTextFields() {
        countryTextField.resignFirstResponder()
        plantationTextField.resignFirstResponder()
        flowerTextField.resignFirstResponder()
        varietyTextField.resignFirstResponder()
        sizeTextField.resignFirstResponder()
        awbTextField.resignFirstResponder()
    }
    
    func adjustView() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
                topContainerView.frame = CGRectMake(45, 77, 215, 110)
                bottomContainerView.frame = CGRectMake(45, 197, 215, 106)
            } else {
                topContainerView.frame = CGRectMake(60, 60, 215, 110)
                bottomContainerView.frame = CGRectMake(280, 60, 215, 106)
            }
        }
    }
    
    // MARK: - Actions

    @IBAction func clearButtonClicked(sender: UIButton) {
        countryTextField.text = "---------"
        plantationTextField.text = "---------"
        flowerTextField.text = "---------"
        varietyTextField.text = "---------"
        sizeTextField.text = "---------"
        awbTextField.text = "---------"
        
        state.selectedCountry = nil
        state.selectedPlantation = nil
        state.selectedFlower = nil
        state.selectedVariety = nil
        state.selectedSize = nil
        state.selectedAwb = nil
        
        delegate?.invoiceDetailsGeneralFilterViewDidFilter(self, withState: state)
        self.removeFromSuperview()
    }
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func okButtonClicked(sender: UIButton) {
        self.removeFromSuperview()
        delegate?.invoiceDetailsGeneralFilterViewDidFilter(self, withState: state)
    }
    
    @IBAction func overlayViewClicked(sender: UITapGestureRecognizer) {
        resignTextFields()
    }
    
    @IBAction func textFieldClicked(sender: UITextField) {
        switch sender {
        case countryTextField:
            if let selectedCountry = state.selectedCountry {
                let row = countries.indexOf({ $0.id == selectedCountry.id })!
                countryPickerView.selectRow(row + 1, inComponent: 0, animated: false)
            } else {
                countryPickerView.selectRow(0, inComponent: 0, animated: false)
            }
        case plantationTextField:
            if let selectedPlantation = state.selectedPlantation {
                let row = plantations.indexOf({ $0.id == selectedPlantation.id })!
                plantationPickerView.selectRow(row + 1, inComponent: 0, animated: false)
            } else {
                plantationPickerView.selectRow(0, inComponent: 0, animated: false)
            }
        case flowerTextField:
            if let selectedFlower = state.selectedFlower {
                let row = flowers.indexOf({ $0.id == selectedFlower.id })!
                flowerPickerView.selectRow(row + 1, inComponent: 0, animated: false)
            } else {
                flowerPickerView.selectRow(0, inComponent: 0, animated: false)
            }
        case varietyTextField:
            if let selectedVariety = state.selectedVariety {
                let row = varieties.indexOf({ $0.id == selectedVariety.id })!
                varietyPickerView.selectRow(row + 1, inComponent: 0, animated: false)
            } else {
                varietyPickerView.selectRow(0, inComponent: 0, animated: false)
            }
        case sizeTextField:
            if let selectedSize = state.selectedSize {
                let row = sizes.indexOf({ $0.id == selectedSize.id })!
                sizePickerView.selectRow(row + 1, inComponent: 0, animated: false)
            } else {
                sizePickerView.selectRow(0, inComponent: 0, animated: false)
            }
        case awbTextField:
            if let selectedAwb = state.selectedAwb {
                let row = awbs.indexOf(selectedAwb)!
                awbPickerView.selectRow(row + 1, inComponent: 0, animated: false)
            } else {
                awbPickerView.selectRow(0, inComponent: 0, animated: false)
            }
        default:
            break
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0
        switch pickerView {
        case countryPickerView:
            numberOfRows = countries.count
        case plantationPickerView:
            numberOfRows = plantations.count
        case flowerPickerView:
            numberOfRows = flowers.count
        case varietyPickerView:
            numberOfRows = varieties.count
        case sizePickerView:
            numberOfRows = sizes.count
        case awbPickerView:
            numberOfRows = awbs.count
        default:
            break
        }
        return numberOfRows + 1
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var titleForRow: String = "---------"
        if row > 0 {
            switch pickerView {
            case countryPickerView:
                titleForRow = countries[row - 1].name
            case plantationPickerView:
                titleForRow = plantations[row - 1].name
            case flowerPickerView:
                titleForRow = flowers[row - 1].name
            case varietyPickerView:
                titleForRow = varieties[row - 1].name
            case sizePickerView:
                titleForRow = sizes[row - 1].name
            case awbPickerView:
                titleForRow = awbs[row - 1]
            default:
                break
            }
        }

        return titleForRow
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case countryPickerView:
            if row == 0 {
                state.selectedCountry = nil
            } else {
                state.selectedCountry = countries[row - 1]
            }
        case plantationPickerView:
            if row == 0 {
                state.selectedPlantation = nil
            } else {
                state.selectedPlantation = plantations[row - 1]
            }
        case flowerPickerView:
            if row == 0 {
                state.selectedFlower = nil
            } else {
                state.selectedFlower = flowers[row - 1]
            }
        case varietyPickerView:
            if row == 0 {
                state.selectedVariety = nil
            } else {
                state.selectedVariety = varieties[row - 1]
            }
        case sizePickerView:
            if row == 0 {
                state.selectedSize = nil
            } else {
                state.selectedSize = sizes[row - 1]
            }
        case awbPickerView:
            if row == 0 {
                state.selectedAwb = nil
            } else {
                state.selectedAwb = awbs[row - 1]
            }
        default:
            break
        }
        
        resignTextFields()
        populateView()
    }
}

struct InvoiceDetailsGeneralFilterViewState {
    var selectedCountry: Country?
    var selectedPlantation: Plantation?
    var selectedFlower: Flower?
    var selectedVariety: Variety?
    var selectedSize: Flower.Size?
    var selectedAwb: String?
}

protocol InvoiceDetailsGeneralFilterViewDelegate: NSObjectProtocol {
    func invoiceDetailsGeneralFilterViewDidFilter(invoiceDetailsGeneralFilterView: InvoiceDetailsGeneralFilterView, withState state: InvoiceDetailsGeneralFilterViewState)
}
