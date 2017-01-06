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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactPersonLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var detailedInforamationLabel: UILabel!
    @IBOutlet weak var informationAboutCompanyLabel: UILabel!
    @IBOutlet weak var informationHintLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = CustomLocalisedString("User registration")
        nameLabel.text = CustomLocalisedString("Name of firm or of the person")
        contactPersonLabel.text = CustomLocalisedString("Contact person")
        countryLabel.text = CustomLocalisedString("Country")
        cityLabel.text = CustomLocalisedString("City")
        phoneLabel.text = CustomLocalisedString("Phone")
        informationAboutCompanyLabel.text = CustomLocalisedString("The information about your company")
        detailedInforamationLabel.text = CustomLocalisedString("The detailed information")
        informationHintLabel.text = CustomLocalisedString("The field is not obligatory for filling")
        sendButton.setTitle(CustomLocalisedString("SEND SIGN UP REQUEST"), for: UIControlState())
        
        informationAboutCompanyTextView.layer.cornerRadius = 5
        adjustViews()
        adjustTextFields()
        scrollView.delaysContentTouches = false
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
        
        if isPortraitOrientation() {
            scrollView.contentSize = CGSize(width: 320, height: 1321)
        } else {
            scrollView.contentSize = CGSize(width: 320, height: 1267)
        }
    }
    
    func adjustTextFields() {
        var toolbar = UIToolbar()
        toolbar.sizeToFit()
        var doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: phoneTextField,
                                         action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        phoneTextField.inputAccessoryView = toolbar
        
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
            
            Utils.showErrorWithMessage(CustomLocalisedString("Registration fields are required"), inViewController: self)
        } else {
            RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
            ApiManager.sendSignUpRequest(name: name, country: country, city: city, phone: phoneTextField.text, viber: viberTextField.text, whatsApp: whatsAppTextField.text, skype: skypeTextField.text, email: email, aboutCompany: informationAboutCompanyTextView.text, completion: { (success, error) in
                RBHUD.sharedInstance.hideLoader()
                if success {
                    Utils.showSuccessWithMessage(CustomLocalisedString("Registration request was successfully sent"), inViewController: self)
                } else {
                    Utils.showErrorWithMessage(CustomLocalisedString("Registration request sending error"), inViewController: self)
                }
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func sendButtonClicked(_ sender: AnyObject) {
        let alertController = UIAlertController(title: CustomLocalisedString("Sending request"), message: CustomLocalisedString("Send the registration request of a new user"), preferredStyle: .alert)
        let yesAlertAction = UIAlertAction(title: CustomLocalisedString("YES"), style: .default) { alertAction in
            self.sendSignUpRequest()
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
}
