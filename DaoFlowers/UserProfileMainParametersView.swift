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
        
        scrollView.contentSize = CGSize(width: 320, height: 700)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: recoveryPhoneNumberTextField,
                                         action: #selector(UIResponder.resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        recoveryPhoneNumberTextField.inputAccessoryView = toolbar
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var nsString = NSString(string: textField.text!)
        nsString = nsString.replacingCharacters(in: range, with: string) as NSString
        let text = nsString as String
        
        switch textField {
        case recoveryEmailTextField:
            customer.recoveryEmail = text
        case recoveryPhoneNumberTextField:
            customer.recoveryPhone = text
        case organizationTextField:
            customer.organization = text
        case countryCityTextField:
            customer.address = text
        case detailedAddressTextField:
            customer.detailedAddress = text
        case websiteTextField:
            customer.url = text
        default:
            break
        }
        
        delegate?.userProfileMainParametersView(userProfileMainParametersView: self, didChangedCustomer: customer)
        
        return true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

protocol UserProfileMainParametersViewDelegate: NSObjectProtocol {
    func userProfileMainParametersView(userProfileMainParametersView: UserProfileMainParametersView, didChangedCustomer customer: Customer)
}
