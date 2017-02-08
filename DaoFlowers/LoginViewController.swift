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
    @IBOutlet weak var enterButton: UIButton!

    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = CustomLocalisedString("Authorization")
        usernameTextField.placeholder = CustomLocalisedString("Login")
        passwordTextField.placeholder = CustomLocalisedString("Password")
        enterButton.setTitle(CustomLocalisedString("ENTER"), for: UIControlState())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameTextField.becomeFirstResponder()
    }
    
    // MARK: Private Methods
    
    func login() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.loginWithUsername(self.usernameTextField.text!, andPassword: self.passwordTextField.text!) { (user, error) in
            RBHUD.sharedInstance.hideLoader()
            if let user = user {
                ApiManager.fetchUserAndChildrenWithUser(user, completion: { (user, error) in
                    if let user = user {
                        var language = Language.English
                        if let langId = user.langId {
                            language = Language.languageById(id: langId)
                        }
                        let userDefaults = UserDefaults.standard
                        userDefaults.set(language.rawValue, forKey: K.UserDefaultsKey.Language)
                        userDefaults.synchronize()
                        user.save()
                        self.navigationController!.presentingViewController!.dismiss(animated: true, completion: nil)
                    } else {
                        Utils.showError(error!, inViewController: self)
                    }
                })
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        self.login()
    }
    
    @IBAction func backButtonClicked(_ sender: UIBarButtonItem) {
        self.navigationController!.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.usernameTextField) {
            self.passwordTextField.becomeFirstResponder()
        } else if textField.isEqual(self.passwordTextField) {
            self.login()
        }
        
        return true
    }
}
