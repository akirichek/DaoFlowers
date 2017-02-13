//
//  UserProfileMainParametersView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 1/23/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class UserProfileMainParametersView: UIView, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recoveryEmailTextField: UITextField!
    @IBOutlet weak var recoveryPhoneNumberTextField: UITextField!
    @IBOutlet weak var organizationTextField: UITextField!
    @IBOutlet weak var countryCityTextField: UITextField!
    @IBOutlet weak var detailedAddressTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var markingLabel: UILabel!
    @IBOutlet weak var recoveryEmailLabel: UILabel!
    @IBOutlet weak var recoveryPhoneNumberLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var countryCityLabel: UILabel!
    @IBOutlet weak var detailedAddressLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: UserProfileMainParametersViewDelegate?
    
    var customer: Customer!
    
    func reloadData() {
        markingLabel.text = customer.marking
        recoveryEmailTextField.text = customer.recoveryEmail
        recoveryPhoneNumberTextField.text = customer.recoveryPhone
        organizationTextField.text = customer.organization
        countryCityTextField.text = customer.address
        detailedAddressTextField.text = customer.detailedAddress
        websiteTextField.text = customer.url
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        recoveryEmailLabel.text = CustomLocalisedString("Recovery email")
        recoveryPhoneNumberLabel.text = CustomLocalisedString("Recovery phone number")
        organizationLabel.text = CustomLocalisedString("Organization")
        countryCityLabel.text = CustomLocalisedString("Country, city")
        detailedAddressLabel.text = CustomLocalisedString("Detailed address")
        websiteLabel.text = CustomLocalisedString("Website")
        
        scrollView.contentSize = CGSize(width: 320, height: 723)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: recoveryPhoneNumberTextField,
                                         action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        recoveryPhoneNumberTextField.inputAccessoryView = toolbar
        
        saveButton.setTitle(CustomLocalisedString("Save"), for: UIControlState())
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        endEditing(true)
        customer.recoveryEmail = recoveryEmailTextField.text
        customer.recoveryPhone = recoveryPhoneNumberTextField.text
        customer.organization = organizationTextField.text
        customer.address = countryCityTextField.text
        customer.detailedAddress = detailedAddressTextField.text
        customer.url = websiteTextField.text
        delegate?.userProfileMainParametersView(userProfileMainParametersView: self, saveButtonClickedWithCustomer: customer)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

protocol UserProfileMainParametersViewDelegate: NSObjectProtocol {
    func userProfileMainParametersView(userProfileMainParametersView: UserProfileMainParametersView, saveButtonClickedWithCustomer customer: Customer)
}
