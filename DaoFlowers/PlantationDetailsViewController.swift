//
//  PlantationDetailsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/9/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class PlantationDetailsViewController: BaseViewController, PageViewerDataSource, VarietiesByPlantationPageViewDelegate {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var farmLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    
    var pageScrollViewContentOffsetY: CGFloat = 0
    var pageViewer: PageViewer!
    var plantation: Plantation!
    var varieties: [Int:[Variety]] = [:]
    var flowers: [Flower] = []
    var colors: [Color] = []
//    var selectedVariety: Variety!
    var selectedColor: Color?
    var pageViewStates: [Int: VarietiesByPlantationPageViewState] = [:]
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topContainerView.frame = self.topContainerViewFrame()
        self.pageViewerContainerView.frame = self.pageViewerFrame()
        let pageViewer = NSBundle.mainBundle().loadNibNamed("PageViewer", owner: self, options: nil).first as! PageViewer
        pageViewer.frame = self.pageViewerContainerView.bounds
        pageViewer.dataSource = self
        pageViewer.viewWillTransitionToSize = self.pageViewerFrame().size
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
        self.title = "\(plantation.name) (\(plantation.brand))"
        self.fetchVarieties()
        self.infoContainerView.layer.cornerRadius = 5
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        var contentContainerViewFrame = self.contentContainerView.frame
        contentContainerViewFrame.origin.y = 0
        contentContainerViewFrame.size.height = self.viewWillTransitionToSize.height
        self.contentContainerView.frame = contentContainerViewFrame
        self.viewWillTransitionToSize = size
        self.topContainerView.frame = self.topContainerViewFrame()
        
        var pageViewerContainerViewFrame = self.pageViewerContainerView.frame
        pageViewerContainerViewFrame.size.height += pageViewerContainerViewFrame.origin.y - self.pageViewerFrame().origin.y
        pageViewerContainerViewFrame.origin.y = self.pageViewerFrame().origin.y
        self.pageViewerContainerView.frame = pageViewerContainerViewFrame
        
        if let page = self.pageViewer.pageAtIndex(self.pageViewer.indexOfCurrentPage) as? VarietiesByPlantationPageView {
            page.collectionView.contentOffset = CGPointMake(0, 0)
            pageScrollViewContentOffsetY = 0
            page.viewWillTransitionToSize = size
            page.reloadData()
        }
        self.pageViewer.viewWillTransitionToSize = self.pageViewerFrame().size
        self.pageViewer.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let destinationViewController = segue.destinationViewController
//        if let varietyDetailsViewController = destinationViewController as? VarietyDetailsViewController {
//            varietyDetailsViewController.variety = self.selectedVariety
//        }
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonClicked(sender: UIBarButtonItem) {
        if let page = self.pageViewer.pageAtIndex(pageViewer.indexOfCurrentPage) as? VarietiesByPlantationPageView {
            let indexOfCurrentPage = pageViewer.indexOfCurrentPage
            var pageViewState = pageViewStates[indexOfCurrentPage]!
            pageViewState.filter = !pageViewState.filter
            page.state = pageViewState
            page.reloadData()
            pageViewStates[indexOfCurrentPage] = pageViewState
        }
    }
    
    @IBAction func infoButtonClicked(sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Private Methods
    
    func fetchVarieties() {
        if let currentUser = User.currentUser() {
            RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
            ApiManager.fetchVarietiesByPlantation(self.plantation, user: currentUser) { (varieties, error) in
                RBHUD.sharedInstance.hideLoader()
                if let varieties = varieties {
                    for variety in varieties {
                        if var varietiesByFlower = self.varieties[variety.flower.id] {
                            varietiesByFlower.append(variety)
                            self.varieties[variety.flower.id] = varietiesByFlower
                        } else {
                            self.varieties[variety.flower.id] = [variety]
                            self.flowers.append(variety.flower)
                        }
                        
                        if self.colors.indexOf({$0.id == variety.color.id}) == nil {
                            if variety.color.id == -1 {
                                self.colors.insert(variety.color, atIndex: 0)
                            } else {
                                self.colors.append(variety.color)
                            }
                        }
                    }
                    self.pageViewer.reloadData()
                } else {
                    Utils.showError(error!, inViewController: self)
                }
            }
        }
    }

    func pageViewerFrame() -> CGRect {
        let contentViewFrame = self.contentViewFrame()
        let topContainerViewFrame = self.topContainerView.frame
        let pageViewerFrame = CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y + topContainerViewFrame.height + self.contentContainerView.frame.origin.y, contentViewFrame.width, contentViewFrame.height - topContainerViewFrame.height - contentContainerView.frame.origin.y)
        return pageViewerFrame
    }
    
    func topContainerViewFrame() -> CGRect {
        var topContainerViewFrame = self.topContainerView.frame
        topContainerViewFrame.origin.y = self.contentViewFrame().origin.y
        return topContainerViewFrame
    }
    
    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(pageViewer: PageViewer) -> Int {
        return self.flowers.count
    }
    
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return self.flowers[index].name
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: VarietiesByPlantationPageView! = reusableView as? VarietiesByPlantationPageView
        
        if pageView == nil {
            pageView = NSBundle.mainBundle().loadNibNamed("VarietiesByPlantationPageView", owner: self, options: nil).first as! VarietiesByPlantationPageView
            pageView.delegate = self
        }
        
        pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
        
        var pageViewState: VarietiesByPlantationPageViewState!
        if self.pageViewStates[index] == nil {
            pageViewState = VarietiesByPlantationPageViewState(filter: false,
                                                   searchString: "",
                                                   varieties: varieties[flowers[index].id],
                                                   selectedColor: nil,
                                                   colors: self.colors,
                                                   index: index)
            self.pageViewStates[index] = pageViewState
        } else {
            pageViewState = self.pageViewStates[index]
        }
        
        pageView.state = pageViewState
        pageView.reloadData()
        
        self.view.endEditing(true)

        
        return pageView!
    }
    
    // MARK: - VarietiesByPlantationPageViewDelegate
    
    func varietiesByPlantationPageView(varietiesByPlantationPageView: VarietiesByPlantationPageView, didSelectVariety variety: Variety) {
        
    }
    
    func varietiesByPlantationPageView(varietiesByPlantationPageView: VarietiesByPlantationPageView, didChangeState state: VarietiesByPlantationPageViewState) {
        
    }
    
    func varietiesByPlantationPageView(varietiesByPlantationPageView: VarietiesByPlantationPageView, scrollViewDidScroll scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            var contentContainerViewFrame = self.contentContainerView.frame
            if contentContainerViewFrame.origin.y < 0 {
                let deltaContentOffsetY = pageScrollViewContentOffsetY - scrollView.contentOffset.y
                if contentContainerViewFrame.origin.y + deltaContentOffsetY > 0 {
                    contentContainerViewFrame.origin.y = 0
                    contentContainerViewFrame.size.height = self.viewWillTransitionToSize.height
                } else {
                    contentContainerViewFrame.origin.y += deltaContentOffsetY
                    contentContainerViewFrame.size.height -= deltaContentOffsetY
                }
                
                self.contentContainerView.frame = contentContainerViewFrame
                self.pageViewer.viewWillTransitionToSize = self.pageViewerFrame().size
                self.pageViewer.reloadData()
                
                scrollView.contentOffset = CGPointMake(0, 0)
            }
        } else {
            if self.contentContainerView.frame.origin.y > -self.topContainerView.frame.height {
                var contentContainerViewFrame = self.contentContainerView.frame
                if contentContainerViewFrame.origin.y - scrollView.contentOffset.y < -self.topContainerView.frame.height {
                    contentContainerViewFrame.origin.y = -self.topContainerView.frame.height
                    contentContainerViewFrame.size.height = self.viewWillTransitionToSize.height + self.topContainerView.frame.height
                } else {
                    contentContainerViewFrame.origin.y -= scrollView.contentOffset.y
                    contentContainerViewFrame.size.height += scrollView.contentOffset.y
                }
                
                self.contentContainerView.frame = contentContainerViewFrame
                scrollView.contentOffset = CGPointMake(0, 0)
                self.pageViewer.viewWillTransitionToSize = self.pageViewerFrame().size
                self.pageViewer.reloadData()
            }
        }
        
        pageScrollViewContentOffsetY = scrollView.contentOffset.y
    }
}