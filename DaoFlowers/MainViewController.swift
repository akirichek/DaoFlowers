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
    @IBOutlet weak var menuContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    
    var currentViewController: UIViewController?
    var previousTouchPoint: CGPoint!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuViewController = self.childViewControllers.first as! MenuViewController
        menuViewController.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Flowers, sender: self)
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
        var newConstant: CGFloat;
        if drugged {
            if abs(self.menuContainerLeadingConstraint.constant) >= (self.menuContainerView.frame.width / 2) {
                newConstant = -(self.menuContainerView.bounds.size.width)
            } else {
                newConstant = 0
            }
        } else {
            if self.menuContainerLeadingConstraint.constant == 0 {
                newConstant = -(self.menuContainerView.bounds.size.width)
            } else {
                newConstant = 0
            }
        }
        
        self.panGestureRecognizer.enabled = !Bool(newConstant)
        self.menuContainerLeadingConstraint.constant = newConstant
        let alpha: CGFloat
        
        if newConstant == 0 {
            alpha = 0.75
        } else {
            alpha = 0
        }
        
        UIView.animateWithDuration(0.3) {
            self.hiddenView.alpha = alpha
            self.view.layoutIfNeeded()
        }
    }
    
    func dragMenu(sender: UIGestureRecognizer) {
        let point: CGPoint = sender.locationInView(self.view)
        if self.previousTouchPoint != nil {
            let deltaX = point.x - self.previousTouchPoint.x
            if (self.menuContainerLeadingConstraint.constant + deltaX <= 0) {
                self.hiddenView.alpha = (self.menuContainerView.frame.width + self.menuContainerLeadingConstraint.constant) / self.view.frame.width
                self.menuContainerLeadingConstraint.constant += deltaX
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
        if (point.x - self.menuContainerView.frame.width - self.menuContainerLeadingConstraint.constant <= 0) ||
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
        case .Plantations:
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Plantations, sender: self)
        }
        
        self.view.layoutIfNeeded()
        self.animateMenu(false)
    }
    
    // MARK: MenuButtonHandler
    
    func menuButtonClicked() {
        self.animateMenu(false)
    }
}