//
//  SendCommentViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/25/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class SendCommentViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var workPhoneTextField: UITextField!
    @IBOutlet weak var mobilePhoneTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var skypeTextField: UITextField!
    @IBOutlet weak var viberTextField: UITextField!
    @IBOutlet weak var whatsAppTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    var subjectPickerView: UIPickerView!
    var subjects: [String]!
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsTextView.layer.cornerRadius = 5
        adjustViews()
        adjustTextFields()
        subjects = ["", "Order", "Order status", "Personal orders", "Preference cards", "Flower purchases statistics", "My mixes", "Absolute prohibition", "Control panel", "Flower catalogue", "Plantations catalogue", "Price information request", "Principles of work", "Logistics", "Application functioning general questions"]
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        adjustViews()
    }
    
    // MARK: - Private Methods
    
    func adjustViews() {
        var scrollViewFrame = scrollView.frame
        scrollViewFrame.origin.y = contentViewFrame().origin.y
        scrollViewFrame.size.height = contentViewFrame().height
        scrollView.frame = scrollViewFrame
        
        if isPortraitOrientation() {
            scrollView.contentSize = CGSizeMake(320, 979)
        } else {
            scrollView.contentSize = CGSizeMake(320, 925)
        }
    }
    
    func adjustTextFields() {
        var toolbar = UIToolbar()
        toolbar.sizeToFit()
        var doneButton = UIBarButtonItem(title: "Done",
                                         style: UIBarButtonItemStyle.Done,
                                         target: workPhoneTextField,
                                         action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        workPhoneTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: "Done",
                                     style: UIBarButtonItemStyle.Done,
                                     target: mobilePhoneTextField,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        mobilePhoneTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: "Done",
                                     style: UIBarButtonItemStyle.Done,
                                     target: viberTextField,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        viberTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: "Done",
                                     style: UIBarButtonItemStyle.Done,
                                     target: commentsTextView,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        commentsTextView.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    
    @IBAction func selectSubjectButtonClicked(sender: UIButton) {
        subjectTextField.resignFirstResponder()
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        subjectTextField.inputView = pickerView
        subjectTextField.becomeFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subjects.count
    }
    
    // MARK: - UIPickerViewDelegate

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let label = UILabel(frame: CGRectMake(0, 0, 320, 50))
        label.text = subjects[row]
        label.numberOfLines = 0
        label.textAlignment = .Center
        return label
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        subjectTextField.text = subjects[row]
        subjectTextField.resignFirstResponder()
        subjectTextField.inputView = nil
    }
}
