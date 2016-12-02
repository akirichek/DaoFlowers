//
//  OrderCallbackViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/25/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class OrderCallbackViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var skypeTextField: UITextField!
    @IBOutlet weak var viberTextField: UITextField!
    @IBOutlet weak var whatsAppTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var generalInfoContainerView: UIView!
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentsTextView.layer.cornerRadius = 5
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
        
        if User.currentUser() == nil {
            if isPortraitOrientation() {
                scrollView.contentSize = CGSizeMake(320, 1117)
            } else {
                scrollView.contentSize = CGSizeMake(320, 1063)
            }
        } else {
            var generalInfoContainerViewFrame = generalInfoContainerView.frame
            generalInfoContainerViewFrame.origin.y = 0
            generalInfoContainerView.frame = generalInfoContainerViewFrame
            if isPortraitOrientation() {
                scrollView.contentSize = CGSizeMake(320, 772)
            } else {
                scrollView.contentSize = CGSizeMake(320, 718)
            }
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
                                     target: commentsTextView,
                                     action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        commentsTextView.inputAccessoryView = toolbar
    }
    
    func orderCallback() {
        let name = nameTextField.text!
        let company = companyTextField.text!
        let country = countryTextField.text!
        let city = cityTextField.text!
        
        if name.characters.count == 0 ||
            company.characters.count == 0 ||
            country.characters.count == 0 ||
            city.characters.count == 0 {
            Utils.showErrorWithMessage("Name, Company, Country and City fields are required", inViewController: self)
        } else {
            RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
            ApiManager.orderCallback(name: name,
                                     company: company,
                                     country: country,
                                     city: city,
                                     phone: phoneTextField.text,
                                     viber: viberTextField.text,
                                     whatsApp: whatsAppTextField.text,
                                     skype: skypeTextField.text,
                                     email: emailTextField.text,
                                     comment: commentsTextView.text) { (success, error) in
                                        RBHUD.sharedInstance.hideLoader()
                                        if success {
                                            Utils.showSuccessWithMessage("Call-back request was successfully sent.", inViewController: self)
                                        } else {
                                            Utils.showErrorWithMessage("Call-back request sending error.", inViewController: self)
                                        }
            }
        }
    }
    
    // MARK: - Actions

    @IBAction func orderCallbackButtonClicked(sender: UIButton) {
        let alertController = UIAlertController(title: "Sending request", message: "Send call-back request?", preferredStyle: .Alert)
        let yesAlertAction = UIAlertAction(title: "YES", style: .Default) { alertAction in
            self.orderCallback()
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
