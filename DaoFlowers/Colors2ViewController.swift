//
//  Colors2ViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/30/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class Colors2ViewController: BaseViewController, PageViewerDataSource, ColorsPageViewDelegate {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    var pageViewer: PageViewer!
    var flowers: [Flower] = []
    var selectedFlower: Flower!
    var colors: [Int: [Color]] = [:]
    var selectedColor: Color?
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    var needsSelectPageView: Bool = true
    
    // MARK - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        let pageViewer = NSBundle.mainBundle().loadNibNamed("PageViewer", owner: self, options: nil).first as! PageViewer
        pageViewer.dataSource = self
        pageViewer.translatesAutoresizingMaskIntoConstraints = false
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
        self.adjustConstraintsForItem(self.pageViewer, toItem: self.pageViewerContainerView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needsSelectPageView {
            let index = flowers.indexOf({$0.id == self.selectedFlower.id})!
            self.pageViewer.selectPageAtIndex(index)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        needsSelectPageView = false
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        if let page = self.pageViewer.pageAtIndex(self.pageViewer.indexOfCurrentPage) as? ColorsPageView {
            page.viewWillTransitionToSize = size
            page.reloadData()
        }
        self.pageViewer.viewWillTransitionToSize = size
        self.pageViewer.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let varietiesViewController = destinationViewController as? VarietiesViewController {
            let colorsPageView = sender as! ColorsPageView
            varietiesViewController.flower = self.selectedFlower
            varietiesViewController.colors = colorsPageView.colors!
        }
    }
    
    // MARK: - Private Methods
    
    func fetchColorsForPageViewIndex(indexOfPageView: Int) {
        let flower = flowers[indexOfPageView]
        ApiManager.fetchColorsByFlower(flower, completion: { (colors, error) in
            if let colors = colors {
                if let page = self.pageViewer.pageAtIndex(indexOfPageView) as? ColorsPageView {
                    page.colors = colors
                    self.colors[indexOfPageView] = colors
                }
            } else {
                Utils.showError(error!, inViewController: self)
            }
        })
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonClicked(sender: UIBarButtonItem) {

    }
    
    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(pageViewer: PageViewer) -> Int {
        return self.flowers.count
    }
    
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return self.flowers[index].name
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: ColorsPageView! = reusableView as? ColorsPageView
        
        if pageView == nil {
            pageView = NSBundle.mainBundle().loadNibNamed("ColorsPageView", owner: self, options: nil).first as! ColorsPageView
            pageView.delegate = self
        }
        
        pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
        
        if let colors = self.colors[index] {
            pageView.colors = colors
        } else {
            pageView.colors = nil
            fetchColorsForPageViewIndex(index)
        }
        
        self.view.endEditing(true)
        
        return pageView!
    }

    // MARK: - ColorsPageViewDelegate
    
    func colorsPageView(colorsPageView: ColorsPageView, didSelectColor color: Color) {
        self.selectedColor = color
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Varieties,
                                        sender: colorsPageView)
    }
}