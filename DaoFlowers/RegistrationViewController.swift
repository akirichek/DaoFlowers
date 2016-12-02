//
//  RegistrationViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 12/1/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class RegistrationViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contactPersonTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var skypeTextField: UITextField!
    @IBOutlet weak var viberTextField: UITextField!
    @IBOutlet weak var whatsAppTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var informationAboutCompanyTextView: UITextView!
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        informationAboutCompanyTextView.layer.cornerRadius = 5
        adjustViews()
        adjustTextFields()
        scrollView.delaysContentTouches = false
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
            scrollView.contentSize = CGSizeMake(320, 1321)
        } else {
            scrollView.contentSize = CGSizeMake(320, 1267)
        }
    }
    
    func adjustTextFields() {
        var toolbar = UIToolbar()
        toolbar.sizeToFit()
        var doneButton = UIBarButtonItem(title: "Done",
                                         style: UIBarButtonItemStyle.Done,
                                         target: phoneTextField,
                                         action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        phoneTextField.inputAccessoryView = toolbar
        
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
                                     target: informationAboutCompanyTextView,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        informationAboutCompanyTextView.inputAccessoryView = toolbar
    }
    
    func sendSignUpRequest() {
        let name = nameTextField.text!
        let country = countryTextField.text!
        let city = cityTextField.text!
        let email = emailTextField.text!
        
        if name.characters.count == 0 ||
            country.characters.count == 0 ||
            city.characters.count == 0 ||
            email.characters.count == 0 {
            
            Utils.showErrorWithMessage("Name, Country, City, and Email fields are required", inViewController: self)
        } else {
            RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
            ApiManager.sendSignUpRequest(name: name, country: country, city: city, phone: phoneTextField.text, viber: viberTextField.text, whatsApp: whatsAppTextField.text, skype: skypeTextField.text, email: email, aboutCompany: informationAboutCompanyTextView.text, completion: { (success, error) in
                RBHUD.sharedInstance.hideLoader()
                if success {
                    Utils.showSuccessWithMessage("Registration request was successfully sent.", inViewController: self)
                } else {
                    Utils.showErrorWithMessage("Registration request sending error. Try again later.", inViewController: self)
                }
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        let alertController = UIAlertController(title: "Sending request", message: "Send the registration request of a new user?", preferredStyle: .Alert)
        let yesAlertAction = UIAlertAction(title: "YES", style: .Default) { alertAction in
            self.sendSignUpRequest()
        }
        let noAlertAction = UIAlertAction(title: "NO", style: .Default, handler: nil)
        alertController.addAction(noAlertAction)
        alertController.addAction(yesAlertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
