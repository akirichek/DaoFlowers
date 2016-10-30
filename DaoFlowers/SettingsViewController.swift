//
//  SettingsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/30/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var languageTextField: UITextField!
    
    var languages: [Language] = [Language.English, Language.Russian, Language.Spanish]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerViewForTextField(self.languageTextField)
    }


    @IBAction func languageButtonClicked(sender: UIButton) {
        languageTextField.becomeFirstResponder()
    }
    
    // MARK: - Private Methods
    
    func doneButtonClicked(sender: UIBarButtonItem) {
        self.languageTextField.resignFirstResponder()
    }
    
    func createPickerViewForTextField(textField: UITextField) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.tintColor = UIColor.redColor()
        pickerView.backgroundColor = UIColor.clearColor()
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
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let lang = languages[row]
        let cell = NSBundle.mainBundle().loadNibNamed("LanguagePickerViewCell", owner: self, options: nil).first as! LanguagePickerViewCell
        cell.language = lang
        return cell
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }
}
