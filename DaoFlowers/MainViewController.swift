//
//  MainViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, MenuViewControllerDelegate, MenuButtonHandler {
    
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    
    var currentViewController: UIViewController?
    var previousTouchPoint: CGPoint!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuViewController = self.childViewControllers.first as! MenuViewController
        menuViewController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let menuViewController = self.childViewControllers.first as! MenuViewController
        menuViewController.reloadData()
        //self.animateMenu(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if currentViewController == nil {
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Flowers, sender: self)
        }
        //self.animateMenu(false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let navigationController = destinationViewController as? UINavigationController {
            if let rootViewController = navigationController.viewControllers[0] as? BaseViewController {
                rootViewController.menuButtonHandler = self
            }
        }
    }
    
    // MARK: Private Methods
    
    func animateMenu(drugged: Bool) {
        self.view.layoutIfNeeded()
        var newConstant: CGFloat;
        var menuViewFrame = self.menuContainerView.frame
        if drugged {
            if abs(menuViewFrame.origin.x) >= (self.menuContainerView.frame.width / 2) {
                newConstant = -(self.menuContainerView.bounds.size.width)
            } else {
                newConstant = 0
            }
        } else {
            if menuViewFrame.origin.x == 0 {
                newConstant = -(self.menuContainerView.bounds.size.width)
            } else {
                newConstant = 0
            }
        }
        
        self.panGestureRecognizer.enabled = !Bool(newConstant)
        menuViewFrame.origin.x = newConstant
        let alpha: CGFloat
        
        if newConstant == 0 {
            alpha = 0.75
        } else {
            alpha = 0
        }
        
        UIView.animateWithDuration(0.3) {
            self.hiddenView.alpha = alpha
            self.menuContainerView.frame = menuViewFrame
        }
    }
    
    func dragMenu(sender: UIGestureRecognizer) {
        let point: CGPoint = sender.locationInView(self.view)
        if self.previousTouchPoint != nil {
            let deltaX = point.x - self.previousTouchPoint.x
            if (self.menuContainerView.frame.origin.x + deltaX <= 0) {
                self.hiddenView.alpha = (self.menuContainerView.frame.width + self.menuContainerView.frame.origin.x) / self.view.frame.width
                var menuViewFrame = self.menuContainerView.frame
                menuViewFrame.origin.x += deltaX
                self.menuContainerView.frame = menuViewFrame
            }
        }
        
        self.previousTouchPoint = point
        
        if sender.state == UIGestureRecognizerState.Ended ||
            sender.state == UIGestureRecognizerState.Cancelled {
            self.previousTouchPoint = nil
            self.animateMenu(true)
        }
    }
    
    // MARK: Actions
    
    @IBAction func hiddenViewClicked(sender: UITapGestureRecognizer) {
        self.animateMenu(false)
    }
    
    @IBAction func panGestureDidDragging(sender: UIPanGestureRecognizer) {
        let point: CGPoint = sender.locationInView(self.view)
        if (point.x - self.menuContainerView.frame.width - self.menuContainerView.frame.origin.x <= 0) ||
            self.previousTouchPoint != nil {
            self.dragMenu(sender)
        }
    }
    
    @IBAction func screenEdgePanGestureDidDragging(sender: UIScreenEdgePanGestureRecognizer) {
        self.dragMenu(sender)
    }

    // MARK: MenuViewControllerDelegate
    
    func menuViewController(menuViewController: MenuViewController, didSelectMenuSection menuSection: MenuSection) {
        switch menuSection {
        case .Varieties:
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Flowers, sender: self)
            self.animateMenu(false)
        case .Plantations:
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Countries, sender: self)
            self.animateMenu(false)
        case .CurrentOrders:
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.CurrentOrders, sender: self)
            self.animateMenu(false)
        case .Documents:
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Documents, sender: self)
            self.animateMenu(false)
        case .Login:
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Login, sender: self)
            //self.animateMenu(false)
        case .Settings:
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Settings, sender: self)
            self.animateMenu(false)
        case .Logout:
            User.currentUser()?.logOut()
            let menuViewController = self.childViewControllers.first as! MenuViewController
            menuViewController.reloadData()
        default:
            break
        }
    }
    
    // MARK: MenuButtonHandler
    
    func menuButtonClicked() {
        let menuViewController = self.childViewControllers.first as! MenuViewController
        menuViewController.reloadData()
        self.animateMenu(false)
    }
}