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
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var workPhoneTextField: UITextField!
    @IBOutlet weak var mobilePhoneTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var skypeTextField: UITextField!
    @IBOutlet weak var viberTextField: UITextField!
    @IBOutlet weak var whatsAppTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var workPhoneLabel: UILabel!
    @IBOutlet weak var mobilePhoneLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var generalInfoContainerView: UIView!
    var subjectPickerView: UIPickerView!
    var subjects: [String] = []
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = CustomLocalisedString("Send comment")
        nameLabel.text = CustomLocalisedString("Name")
        companyLabel.text = CustomLocalisedString("Company")
        cityLabel.text = CustomLocalisedString("City")
        workPhoneLabel.text = CustomLocalisedString("Work phone")
        mobilePhoneLabel.text = CustomLocalisedString("Mobile phone")
        subjectLabel.text = CustomLocalisedString("Subject")
        selectButton.setTitle(CustomLocalisedString("Select"), for: UIControlState())
        commentsLabel.text = CustomLocalisedString("Your comments");
        sendButton.setTitle(CustomLocalisedString("SEND COMMENT"), for: UIControlState())
        commentsTextView.layer.cornerRadius = 5
        adjustViews()
        adjustTextFields()
        scrollView.delaysContentTouches = false
        
        if (LanguageManager.currentLanguage() == .English) {
            subjects = ["", "Order", "Order status", "Personal orders", "Preference cards", "Flower purchases statistics", "My mixes", "Absolute prohibition", "Control panel", "Flower catalogue", "Plantations catalogue"]
        }
        
        subjects += [CustomLocalisedString("Price information request"), CustomLocalisedString("Principles of work"), CustomLocalisedString("Logistics"), CustomLocalisedString("Application functioning general questions")]
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        adjustViews()
    }
    
    // MARK: - Private Methods
    
    func adjustViews() {
        var scrollViewFrame = scrollView.frame
        scrollViewFrame.origin.y = contentViewFrame().origin.y
        scrollViewFrame.size.height = contentViewFrame().height
        scrollView.frame = scrollViewFrame
        
        if User.currentUser() == nil {
            if isPortraitOrientation() {
                scrollView.contentSize = CGSize(width: 320, height: 1187)
            } else {
                scrollView.contentSize = CGSize(width: 320, height: 1133)
            }
        } else {
            var generalInfoContainerViewFrame = generalInfoContainerView.frame
            generalInfoContainerViewFrame.origin.y = 0
            generalInfoContainerView.frame = generalInfoContainerViewFrame
            if isPortraitOrientation() {
                scrollView.contentSize = CGSize(width: 320, height: 900)
            } else {
                scrollView.contentSize = CGSize(width: 320, height: 718)
            }
        }
    }
    
    func adjustTextFields() {
        var toolbar = UIToolbar()
        toolbar.sizeToFit()
        var doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: workPhoneTextField,
                                         action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        workPhoneTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                     style: UIBarButtonItemStyle.done,
                                     target: mobilePhoneTextField,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        mobilePhoneTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                     style: UIBarButtonItemStyle.done,
                                     target: viberTextField,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        viberTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                     style: UIBarButtonItemStyle.done,
                                     target: commentsTextView,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        commentsTextView.inputAccessoryView = toolbar
    }
    
    func sendComment() {
        let name = nameTextField.text!
        let company = companyTextField.text!
        let city = cityTextField.text!
        let workPhone = workPhoneTextField.text!
        let mobilePhone = mobilePhoneTextField.text!
        let email = emailTextField.text!
        let comments = commentsTextView.text!
        let subject = subjectTextField.text!
        
        if comments.characters.count == 0 {
            Utils.showErrorWithMessage(CustomLocalisedString("Send comment fields are required"), inViewController: self)
        } else {
            RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
            ApiManager.sendComment(name: name, company: company, city: city, workPhone: workPhone, mobilePhone: mobilePhone, email: email, viber: viberTextField.text, whatsApp: whatsAppTextField.text, skype: skypeTextField.text, comment: comments, subject: subject, completion: { (success, error) in
                    RBHUD.sharedInstance.hideLoader()
                    if success {
                        Utils.showSuccessWithMessage(CustomLocalisedString("Comment was successfully sent"), inViewController: self)
                    } else {
                        Utils.showErrorWithMessage(CustomLocalisedString("Comment sending error"), inViewController: self)
                    }
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func selectSubjectButtonClicked(_ sender: UIButton) {
        subjectTextField.resignFirstResponder()
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        if let index = subjects.index(of: subjectTextField.text!) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
        subjectTextField.inputView = pickerView
        subjectTextField.becomeFirstResponder()
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: CustomLocalisedString("Sending request"), message: CustomLocalisedString("Send comment question"), preferredStyle: .alert)
        let yesAlertAction = UIAlertAction(title: CustomLocalisedString("YES"), style: .default) { alertAction in
            self.sendComment()
        }
        let noAlertAction = UIAlertAction(title: CustomLocalisedString("NO"), style: .default, handler: nil)
        alertController.addAction(noAlertAction)
        alertController.addAction(yesAlertAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subjects.count
    }
    
    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        label.text = subjects[row]
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        subjectTextField.text = subjects[row]
        subjectTextField.resignFirstResponder()
        subjectTextField.inputView = nil
    }
}
