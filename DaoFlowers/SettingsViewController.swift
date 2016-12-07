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
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var languageValueLabel: UILabel!
    
    var languagePickerView: UIPickerView!
    var languages: [Language] = [Language.English, Language.Russian, Language.Spanish]
    var selectedLanguage: Language! {
        didSet {
            populateView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.languagePickerView = createPickerViewForTextField(self.languageTextField)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let selectedLanguage = userDefaults.stringForKey(K.UserDefaultsKey.Language) {
            self.selectedLanguage = Language(rawValue:selectedLanguage)!
        } else {
            self.selectedLanguage = Language.English
        }
    }

    @IBAction func languageButtonClicked(sender: UIButton) {
        languageTextField.becomeFirstResponder()
        let row = self.languages.indexOf(self.selectedLanguage)!
        self.languagePickerView.selectRow(row, inComponent: 0, animated: false)
        self.arrowImageView.image = UIImage(named: "up_arrow")
        
    }
    
    // MARK: - Private Methods
    
    func populateView() {
        self.languageLabel.text = CustomLocalisedString("Language")
        self.title = CustomLocalisedString("Settings")
        self.languageValueLabel.text = self.selectedLanguage.rawValue
        self.flagImageView.image = UIImage(named: self.selectedLanguage.flagImageName())
    }
    
    func doneButtonClicked(sender: UIBarButtonItem) {
        changeLanguage()
    }
    
    func changeLanguage() {
        self.languageTextField.resignFirstResponder()
        self.arrowImageView.image = UIImage(named: "down_arrow")
        let row = self.languagePickerView.selectedRowInComponent(0)
        let selectedLanguage = languages[row]
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(selectedLanguage.rawValue, forKey: K.UserDefaultsKey.Language)
        userDefaults.synchronize()
        self.selectedLanguage = selectedLanguage
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
        let doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.Done,
                                         target: self,
                                         action: #selector(VarietiesPageView.doneButtonClicked(_:)))
        toolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        
        return pickerView
    }
    
    override func menuButtonClicked(sender: UIBarButtonItem) {
        super.menuButtonClicked(sender)
        languageTextField.resignFirstResponder()
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
        return 80
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeLanguage()
    }
}
