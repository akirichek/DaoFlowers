//
//  LoginViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameTextField.becomeFirstResponder()
    }
    
    // MARK: Private Methods
    
    func login() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.loginWithUsername(self.usernameTextField.text!, andPassword: self.passwordTextField.text!) { (user, error) in
            RBHUD.sharedInstance.hideLoader()
            if let user = user {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(Language.Russian.rawValue, forKey: K.UserDefaultsKey.Language)
                userDefaults.synchronize()
                user.save()
                self.navigationController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        self.login()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(self.usernameTextField) {
            self.passwordTextField.becomeFirstResponder()
        } else if textField.isEqual(self.passwordTextField) {
            self.login()
        }
        
        return true
    }
}
