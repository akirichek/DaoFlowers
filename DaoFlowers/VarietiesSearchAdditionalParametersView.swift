//
//  VarietiesSearchAdditionalParametersView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/26/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesSearchAdditionalParametersView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var flowerTypeTextField: UITextField!
    @IBOutlet weak var colorTypeTextField: UITextField!
    @IBOutlet weak var breederTextField: UITextField!
    
    var flowersSearchParams: [Flower]!
    var colorsSearchParams: [Color]!
    var breedersSearchParams: [Breeder]!
    var flowersPickerView: UIPickerView!
    var colorsPickerView: UIPickerView!
    var breedersPickerView: UIPickerView!
    var selectedTextFiled: UITextField!
    
    var selectedFlower: Flower?
    var selectedColor: Color?
    var selectedBreeder: Breeder?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func flowerTextFieldClicked(sender: UITextField) {
        self.selectedTextFiled = self.flowerTypeTextField
        if self.flowersPickerView == nil {
            self.flowersPickerView = self.createPickerViewForTextField(sender)
        }
    }
    
    @IBAction func colorTextFieldClicked(sender: UITextField) {
        self.selectedTextFiled = self.colorTypeTextField
        if self.colorsPickerView == nil {
            self.colorsPickerView = self.createPickerViewForTextField(sender)
        }
    }
    
    @IBAction func breederTextFieldClicked(sender: UITextField) {
        self.selectedTextFiled = self.breederTextField
        if self.breedersPickerView == nil {
            self.breedersPickerView = self.createPickerViewForTextField(sender)
        }
    }
    
    // MARK: - Private Methods

    func doneButtonClicked(sender: UIBarButtonItem) {
        switch self.selectedTextFiled {
        case self.flowerTypeTextField:
            let row = self.flowersPickerView.selectedRowInComponent(0)
            if row == 0 {
                self.flowerTypeTextField.text = "All"
            } else {
                let flower = self.flowersSearchParams[row - 1]
                self.flowerTypeTextField.text = flower.name
            }
            self.flowerTypeTextField.resignFirstResponder()
        case self.colorTypeTextField:
            let row = self.colorsPickerView.selectedRowInComponent(0)
            if row == 0 {
                self.colorTypeTextField.text = "All"
            } else {
                let color = self.colorsSearchParams[row - 1]
                self.colorTypeTextField.text = color.name
            }
            self.colorTypeTextField.resignFirstResponder()
        case self.breederTextField:
            let row = self.breedersPickerView.selectedRowInComponent(0)
            if row == 0 {
                self.breederTextField.text = "All"
            } else {
                let breeder = self.breedersSearchParams[row - 1]
                self.breederTextField.text = breeder.name
            }
            self.breederTextField.resignFirstResponder()
        default:
            break
        }
    }
    
    func createPickerViewForTextField(textField: UITextField) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(VarietiesSearchAdditionalParametersView.doneButtonClicked(_:)))
        toolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        
        return pickerView
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0
        switch pickerView {
        case self.flowersPickerView:
            numberOfRows = self.flowersSearchParams.count
        case self.colorsPickerView:
            numberOfRows = self.colorsSearchParams.count
        case self.breedersPickerView:
            numberOfRows = self.breedersSearchParams.count
        default:
            break
        }
        return numberOfRows + 1
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var titleForRow = ""
        
        if row == 0 {
            titleForRow = "All"
        } else {
            switch pickerView {
            case self.flowersPickerView:
                let flower = self.flowersSearchParams[row - 1]
                titleForRow = flower.name
            case self.colorsPickerView:
                let color = self.colorsSearchParams[row - 1]
                titleForRow = color.name
            case self.breedersPickerView:
                let breeder = self.breedersSearchParams[row - 1]
                titleForRow = breeder.name
            default:
                break
            }
        }
        return titleForRow
    }
}
