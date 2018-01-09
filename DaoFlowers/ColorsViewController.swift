//
//  ColorsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/30/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class ColorsViewController: BaseViewController, PageViewerDataSource, ColorsPageViewDelegate {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    var pageViewer: PageViewer!
    var flowers: [Flower] = []
    var selectedFlower: Flower!
    var colors: [Int: [Color]] = [:]
    var selectedColor: Color?
    var needsSelectPageView: Bool = true
    
    // MARK - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = CustomLocalisedString("Varieties")
        
        self.pageViewerContainerView.frame = self.contentViewFrame()
        let pageViewer = Bundle.main.loadNibNamed("PageViewer", owner: self, options: nil)?.first as! PageViewer
        pageViewer.frame = self.pageViewerContainerView.bounds
        pageViewer.dataSource = self
        pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needsSelectPageView {
            let index = flowers.index(where: {$0.id == self.selectedFlower.id && $0.isGroup == self.selectedFlower.isGroup})!
            self.pageViewer.selectPageAtIndex(index)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        needsSelectPageView = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        if let page = self.pageViewer.pageAtIndex(self.pageViewer.indexOfCurrentPage) as? ColorsPageView {
            page.viewWillTransitionToSize = size
            page.reloadData()
        }
        self.pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewerContainerView.frame = self.contentViewFrame()
        self.pageViewer.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let varietiesViewController = destinationViewController as? VarietiesViewController {
            let colorsPageView = sender as! ColorsPageView
            varietiesViewController.flower = self.flowers[self.pageViewer.indexOfCurrentPage]
            varietiesViewController.colors = colorsPageView.colors!
            varietiesViewController.selectedColor = self.selectedColor
        }
    }
    
    // MARK: - Private Methods
    
    func fetchColorsForPageViewIndex(_ indexOfPageView: Int) {
        let flower = flowers[indexOfPageView]
        ApiManager.fetchColorsByFlower(flower, completion: { (colors, error) in
            if var colors = colors {
                colors = self.sortedColors(colors)
                if let page = self.pageViewer.pageAtIndex(indexOfPageView) as? ColorsPageView {
                    page.flower = flower
                    page.colors = colors
                    self.colors[indexOfPageView] = colors
                }
            } else {
                Utils.showError(error!, inViewController: self)
            }
        })
    }
    
    func sortedColors(_ colors: [Color]) -> [Color] {
        guard colors.first?.position != nil else {
            return colors
        }
        return colors.sorted(by: { (lhs, rhs) -> Bool in
            if lhs.position == rhs.position {
                return lhs.name < rhs.name
            } else {
                return (lhs.position ?? 0) < (rhs.position ?? 0)
            }
        })
    }
    
    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(_ pageViewer: PageViewer) -> Int {
        return self.flowers.count
    }
    
    func pageViewer(_ pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return self.flowers[index].name
    }
    
    func pageViewer(_ pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: ColorsPageView! = reusableView as? ColorsPageView
        
        if pageView == nil {
            pageView = Bundle.main.loadNibNamed("ColorsPageView", owner: self, options: nil)?.first as! ColorsPageView
            pageView.delegate = self
        }
        
        pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
        
        if let colors = self.colors[index] {
            pageView.flower = flowers[index]
            pageView.colors = colors
        } else {
            pageView.colors = nil
            fetchColorsForPageViewIndex(index)
        }
        
        self.view.endEditing(true)
        
        return pageView!
    }

    // MARK: - ColorsPageViewDelegate
    
    func colorsPageView(_ colorsPageView: ColorsPageView, didSelectColor color: Color) {
        self.selectedColor = color
        self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Varieties,
                                        sender: colorsPageView)
    }
}
