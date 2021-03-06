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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var orderCallbackButton: UIButton!
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = CustomLocalisedString("Order Callback")
        nameLabel.text = CustomLocalisedString("Name")
        companyLabel.text = CustomLocalisedString("Company")
        countryLabel.text = CustomLocalisedString("Country")
        cityLabel.text = CustomLocalisedString("City")
        phoneLabel.text = CustomLocalisedString("Phone")
        commentsLabel.text = CustomLocalisedString("Your comments");
        orderCallbackButton.setTitle(CustomLocalisedString("ORDER CALLBACK"), for: UIControlState())
        
        commentsTextView.layer.cornerRadius = 5
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
        
        if User.currentUser() == nil {
            if isPortraitOrientation() {
                scrollView.contentSize = CGSize(width: 320, height: 1117)
            } else {
                scrollView.contentSize = CGSize(width: 320, height: 1063)
            }
        } else {
            var generalInfoContainerViewFrame = generalInfoContainerView.frame
            generalInfoContainerViewFrame.origin.y = 0
            generalInfoContainerView.frame = generalInfoContainerViewFrame
            if isPortraitOrientation() {
                scrollView.contentSize = CGSize(width: 320, height: 772)
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
                                        Utils.showSuccessWithMessage(CustomLocalisedString("Call-back request was successfully sent"), inViewController: self)
                                    } else {
                                        Utils.showErrorWithMessage(CustomLocalisedString("Call-back request sending error"), inViewController: self)
                                    }
        }
    }
    
    // MARK: - Actions

    @IBAction func orderCallbackButtonClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: CustomLocalisedString("Sending request"), message: CustomLocalisedString("Send call-back request"), preferredStyle: .alert)
        let yesAlertAction = UIAlertAction(title: CustomLocalisedString("YES"), style: .default) { alertAction in
            self.orderCallback()
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
