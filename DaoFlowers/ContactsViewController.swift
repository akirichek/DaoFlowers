//
//  ContactsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/24/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit
import MessageUI

class ContactsViewController: BaseViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var skypeContainerView: UIView!
    @IBOutlet weak var viberContainerView: UIView!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var orderCallbackLabel: UILabel!
    @IBOutlet weak var sendCommentLabel: UILabel!
    @IBOutlet weak var sendCommentContainerView: UIView!
    @IBOutlet weak var orderCallbackContainerView: UIView!
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = CustomLocalisedString("Contacts")
        registrationButton.setTitle(CustomLocalisedString("REGISTRATION"), for: UIControlState())
        orderCallbackLabel.text = CustomLocalisedString("ORDER CALLBACK")
        sendCommentLabel.text = CustomLocalisedString("SEND COMMENT")
        
        adjustShadowForView(skypeContainerView)
        adjustShadowForView(viberContainerView)
        adjustViews()
        adjustButtons()
        
        registrationButton.isHidden = (User.currentUser() != nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        adjustViews()
        adjustButtons()
    }
    
    // MARK: - Private Methods

    func adjustShadowForView(_ view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 2
    }
    
    func adjustViews() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let contentViewFrame = self.contentViewFrame()
            var skypeContainerViewFrame = skypeContainerView.frame
            var viberContainerViewFrame = viberContainerView.frame

            if isPortraitOrientation() {
                skypeContainerViewFrame.size.width = 310
                viberContainerViewFrame.origin.y = 269
                viberContainerViewFrame.origin.x = 5
                viberContainerViewFrame.size.width = 310
            } else {
                skypeContainerViewFrame.size.width = 272
                viberContainerViewFrame.origin.y = contentViewFrame.origin.y + 6
                viberContainerViewFrame.origin.x = 291
                viberContainerViewFrame.size.width = 272
            }
            
            skypeContainerViewFrame.origin.y = contentViewFrame.origin.y + 6
            skypeContainerView.frame = skypeContainerViewFrame
            viberContainerView.frame = viberContainerViewFrame
        }
    }
    
    func adjustButtons() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if isPortraitOrientation() {
                orderCallbackContainerView.frame = CGRect(x: 5, y: 518, width: 152, height: 40)
                sendCommentContainerView.frame = CGRect(x: 163, y: 518, width: 152, height: 40)
                registrationButton.frame = CGRect(x: 84, y: 472, width: 152, height: 40)
            } else {
                orderCallbackContainerView.frame = CGRect(x: 5, y: 270, width: 182, height: 40)
                sendCommentContainerView.frame = CGRect(x: 192, y: 270, width: 182, height: 40)
                registrationButton.frame = CGRect(x: 379, y: 270, width: 182, height: 40)
            }
        }
    }
    
    func callSkypeWithUsername(_ username: String) {
        let url = "skype:\(username)?call"
        
        if UIApplication.shared.canOpenURL(URL(string: url)!) {
            UIApplication.shared.openURL(URL(string: url)!)
        } else {
            Utils.showErrorWithMessage("Skype is not installed.", inViewController: self)
        }
    }
    
    func callViberWithNumber(_ number: String) {
        let viberUrl = "viber://add?number="+number
        if UIApplication.shared.canOpenURL(URL(string: viberUrl)!) {
             UIApplication.shared.openURL(URL(string: viberUrl)!)
        } else {
            Utils.showErrorWithMessage("Viber is not installed.", inViewController: self)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func skypeButtonClicked(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            callSkypeWithUsername("dao-dao")
        case 1:
            callSkypeWithUsername("daoflowers_boris")
        case 2:
            callSkypeWithUsername("daoflowers_vitally")
        case 3:
            callSkypeWithUsername("daoflowers_vlad")
        case 4:
            callSkypeWithUsername("elena_daoflowers")
        default:
            break
        }
    }
    
    @IBAction func viberButtonClicked(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            callViberWithNumber("+31654268152")
        case 1:
            callViberWithNumber("+31657713385")
        default:
            break
        }
    }
    
    @IBAction func whatsappButtonClicked(_ sender: UIButton) {
        let urlString = "Hello DaoFlowers"
        let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url  = URL(string: "whatsapp://send?text=\(urlStringEncoded!)")
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.openURL(url!)
        } else {
            Utils.showErrorWithMessage("WhatsApp is not installed.", inViewController: self)
        }
    }
    
    @IBAction func callButtonClicked(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "tel://+31848303783")!)
    }
    
    @IBAction func emailButtonClicked(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients(["dao@daoflowers.com"])
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func registrationButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Registration, sender: self)
    }
    
    @IBAction func orderCallbackButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: K.Storyboard.SegueIdentifier.OrderCallback, sender: self)
    }
    
    @IBAction func sendCommentButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: K.Storyboard.SegueIdentifier.SendComment, sender: self)
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        if let error = error {
            Utils.showError(error as NSError, inViewController: self)
        }
    }
}
