//
//  VarietiesViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesViewController: BaseViewController, PageViewerDataSource, VarietiesPageViewDelegate {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    var pageViewer: PageViewer!
    
    var flower: Flower!
    var colors: [Color] = []
    var varietiesWithColors: [Int: [Variety]] = [:]
    var selectedVariety: Variety!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageViewer = NSBundle.mainBundle().loadNibNamed("PageViewer", owner: self, options: nil).first as! PageViewer
        pageViewer.dataSource = self
        pageViewer.translatesAutoresizingMaskIntoConstraints = false
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
        self.adjustConstraints()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.pageViewer.viewWillTransitionToSize = size
        self.pageViewer.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let varietyDetailsViewController = destinationViewController as? VarietyDetailsViewController {
            varietyDetailsViewController.variety = self.selectedVariety
        }
    }
    
    // MARK: Private Methods
    
    func fetchVarietiesByColor(color: Color) {
        ApiManager.fetchVarietiesByFlower(self.flower, color: color) { (varieties, error) in
            if let varieties = varieties {
                self.varietiesWithColors[color.id] = varieties
                if let page = self.pageViewer.pageAtIndex(self.colors.indexOf({$0.id == color.id})!) as? VarietiesPageView {
                    page.varieties = varieties
                }
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func adjustConstraints() {
        let leadingConstraint = NSLayoutConstraint(item: self.pageViewer,
                                                   attribute: NSLayoutAttribute.Leading,
                                                   relatedBy: NSLayoutRelation.Equal,
                                                   toItem: self.pageViewerContainerView,
                                                   attribute: NSLayoutAttribute.Leading,
                                                   multiplier: 1,
                                                   constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self.pageViewer,
                                                    attribute: NSLayoutAttribute.Trailing,
                                                    relatedBy: NSLayoutRelation.Equal,
                                                    toItem: self.pageViewerContainerView,
                                                    attribute: NSLayoutAttribute.Trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        let topConstraint = NSLayoutConstraint(item: self.pageViewer,
                                               attribute: NSLayoutAttribute.Top,
                                               relatedBy: NSLayoutRelation.Equal,
                                               toItem: self.pageViewerContainerView,
                                               attribute: NSLayoutAttribute.Top,
                                               multiplier: 1,
                                               constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.pageViewer,
                                                  attribute: NSLayoutAttribute.Bottom,
                                                  relatedBy: NSLayoutRelation.Equal,
                                                  toItem: self.pageViewerContainerView,
                                                  attribute: NSLayoutAttribute.Bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        NSLayoutConstraint.activateConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    
    // MARK: PageViewerDataSource
    
    func pageViewerNumberOfPages(pageViewer: PageViewer) -> Int {
        return self.colors.count
    }
    
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return self.colors[index].name
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var varietiesPageView = reusableView as? VarietiesPageView
        
        if varietiesPageView == nil {
            varietiesPageView = NSBundle.mainBundle().loadNibNamed("VarietiesPageView", owner: self, options: nil).first as? VarietiesPageView
            varietiesPageView?.delegate = self
        }
        
        let color = self.colors[index]
        if let varieties = self.varietiesWithColors[color.id] {
            varietiesPageView?.varieties = varieties
        } else {
            varietiesPageView?.varieties = []
            self.fetchVarietiesByColor(color)
        }
        
        return varietiesPageView!
    }
    
    // MARK: VarietiesPageViewDelegate
    
    func varietiesPageView(varietiesPageView: VarietiesPageView, didSelectVariety variety: Variety) {
        self.selectedVariety = variety
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.VarietyDetails, sender: self)
    }
}
