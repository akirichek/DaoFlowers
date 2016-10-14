//
//  MainViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIGestureRecognizerDelegate, MenuViewControllerDelegate, MenuButtonHandler {
    
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
   // @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var menuContainerLeadingConstraint: NSLayoutConstraint!
    var currentViewController: UIViewController?
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    var previousTouchPoint: CGPoint!
    @IBOutlet weak var hiddenViewForDragging: MenuHiddenView!
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let menuViewController = self.childViewControllers.first as! MenuViewController
        menuViewController.delegate = self
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.test1(_:)))
//        pan.delegate = self;
//        pan.cancelsTouchesInView = false
//        self.hiddenViewForDragging.addGestureRecognizer(pan)
//        let edgeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "userSwipedFromEdge:")
//        edgeGestureRecognizer.edges = UIRectEdge.Left
//        edgeGestureRecognizer.delegate = self
//        self.view.addGestureRecognizer(edgeGestureRecognizer)
    }
    
    
    func test1(pan: UIPanGestureRecognizer) {
        print(#function)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Varieties, sender: self)
//        
//        self.menuContainerLeadingConstraint.constant = -500
//        //self.view.layoutIfNeeded()

//        self.hiddenViewForDragging.menuContainerView = menuViewController.tableView
//        self.hiddenViewForDragging.menuContainerLeadingConstraint = self.menuContainerLeadingConstraint
        
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
    
    func animateMenu() {
        var newConstant: CGFloat;
        
        if self.menuContainerLeadingConstraint.constant == 0 {
            newConstant = -(self.menuContainerView.bounds.size.width)
        } else if self.menuContainerLeadingConstraint.constant == -(self.menuContainerView.bounds.size.width) {
            
            newConstant = 0
        } else if abs(self.menuContainerLeadingConstraint.constant) >= (self.menuContainerView.frame.width / 3) {
            newConstant = -(self.menuContainerView.bounds.size.width)
        } else {
            newConstant = 0
        }
        
        self.panGestureRecognizer.enabled = !Bool(newConstant)
        
        self.menuContainerLeadingConstraint.constant = newConstant
        
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Actions
    
    @IBAction func hiddenViewClicked(sender: UITapGestureRecognizer) {
        self.animateMenu()
    }
    
    @IBAction func dragging(sender: UIPanGestureRecognizer) {
        let point: CGPoint = sender.locationInView(self.view)
        if (point.x - menuContainerView.frame.width - self.menuContainerLeadingConstraint.constant <= 0) ||
            self.previousTouchPoint != nil {
            if self.previousTouchPoint != nil {
                let deltaX = point.x - self.previousTouchPoint.x
                if (self.menuContainerLeadingConstraint.constant + deltaX <= 0) {
                    self.menuContainerLeadingConstraint.constant += deltaX
                }
            }
            
            self.previousTouchPoint = point
            
        }
        
        if sender.state == UIGestureRecognizerState.Ended ||
            sender.state == UIGestureRecognizerState.Cancelled {
            self.previousTouchPoint = nil
            self.animateMenu()
        }
    }

    // MARK: MenuViewControllerDelegate
    
    func menuViewController(menuViewController: MenuViewController, didSelectMenuSection menuSection: MenuSection) {
        switch menuSection {
        case .Varieties:
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Varieties, sender: self)
        case .Plantations:
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Plantations, sender: self)
        }
        
        self.view.layoutIfNeeded()
        self.animateMenu()
    }
    
    // MARK: MenuButtonHandler
    
    func menuButtonClicked() {
        self.animateMenu()
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        print(#function)
        self.previousTouchPoint = nil
        return true
    }
}