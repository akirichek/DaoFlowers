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
        registrationButton.setTitle(CustomLocalisedString("REGISTRATION"), forState: .Normal)
        orderCallbackLabel.text = CustomLocalisedString("ORDER CALLBACK")
        sendCommentLabel.text = CustomLocalisedString("SEND COMMENT")
        
        adjustShadowForView(skypeContainerView)
        adjustShadowForView(viberContainerView)
        adjustViews()
        adjustButtons()
        
        registrationButton.hidden = (User.currentUser() != nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        adjustViews()
        adjustButtons()
    }
    
    // MARK: - Private Methods

    func adjustShadowForView(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 2
    }
    
    func adjustViews() {
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
    
    func adjustButtons() {
        if isPortraitOrientation() {
            orderCallbackContainerView.frame = CGRectMake(5, 518, 152, 40)
            sendCommentContainerView.frame = CGRectMake(163, 518, 152, 40)
            registrationButton.frame = CGRectMake(84, 472, 152, 40)
        } else {
            orderCallbackContainerView.frame = CGRectMake(5, 270, 182, 40)
            sendCommentContainerView.frame = CGRectMake(192, 270, 182, 40)
            registrationButton.frame = CGRectMake(379, 270, 182, 40)
        }
    }
    
    func callSkypeWithUsername(username: String) {
        let url = "skype:\(username)?call"
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: url)!) {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        } else {
            Utils.showErrorWithMessage("Skype is not installed.", inViewController: self)
        }
    }
    
    func callViberWithNumber(number: String) {
        let viberUrl = "viber://add?number="+number
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: viberUrl)!) {
             UIApplication.sharedApplication().openURL(NSURL(string: viberUrl)!)
        } else {
            Utils.showErrorWithMessage("Viber is not installed.", inViewController: self)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func skypeButtonClicked(sender: UIButton) {
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
    
    @IBAction func viberButtonClicked(sender: UIButton) {
        switch sender.tag {
        case 0:
            callViberWithNumber("+31654268152")
        case 1:
            callViberWithNumber("+31657713385")
        default:
            break
        }
    }
    
    @IBAction func whatsappButtonClicked(sender: UIButton) {
        let urlString = "Hello DaoFlowers"
        let urlStringEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")
        
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        } else {
            Utils.showErrorWithMessage("WhatsApp is not installed.", inViewController: self)
        }
    }
    
    @IBAction func callButtonClicked(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://+31848303783")!)
    }
    
    @IBAction func emailButtonClicked(sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients(["dao@daoflowers.com"])
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        if let error = error {
            Utils.showError(error, inViewController: self)
        }
    }
}
