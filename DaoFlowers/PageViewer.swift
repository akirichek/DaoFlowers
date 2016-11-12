//
//  PageViewer.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

let kHeaderPageViewerCollectionViewCellIdentifier = "HeaderPageViewerCollectionViewCellIdentifier"
let kContentPageViewierCollectionViewCellIdentifier = "ContentPageViewierCollectionViewCellIdentifier"

class PageViewer: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var headerCollectionView: UICollectionView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    var viewWillTransitionToSize: CGSize!
    var dataSource: PageViewerDataSource!
    var countOfPages: Int {
        get {
            return self.dataSource.pageViewerNumberOfPages(self)
        }
    }
    var currentContentOffsetX: CGFloat = 0.0
    var indexOfCurrentPage: Int = 0
    
    // MARK: Public Methods
    
    func reloadData() {
        self.headerCollectionView.reloadData()
        self.contentCollectionView.reloadData()
        let contentCollectionViewSize = self.contentCollectionViewSize()
        let currentContentOffsetX = CGFloat(self.indexOfCurrentPage) * contentCollectionViewSize.width
        self.contentCollectionView.setContentOffset(CGPoint(x: currentContentOffsetX, y: 0), animated: true)
    }
    
    func pageAtIndex(index: Int) -> UIView? {
        let cell = self.contentCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
        return cell?.contentView.subviews.first
    }
    
    func selectPageAtIndex(index: Int) {
        let contentCollectionViewSize = self.contentCollectionViewSize()
        let currentContentOffsetX = CGFloat(index) * contentCollectionViewSize.width
        self.contentCollectionView.setContentOffset(CGPoint(x: currentContentOffsetX, y: 0), animated: false)
    }
    
    // MARK: Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        PageViewerFlowLayout.configureLayout(self.contentCollectionView)
        
        let headerCellNib = UINib(nibName:"HeaderPageViewerCollectionViewCell", bundle: nil)
        self.headerCollectionView.registerNib(headerCellNib, forCellWithReuseIdentifier: kHeaderPageViewerCollectionViewCellIdentifier)
        let contentCellNib = UINib(nibName:"ContentPageViewerCollectionViewCell", bundle: nil)
        self.contentCollectionView.registerNib(contentCellNib, forCellWithReuseIdentifier: kContentPageViewierCollectionViewCellIdentifier)
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.pageViewerNumberOfPages(self)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cellIdentifier: String
        
        if collectionView == self.headerCollectionView {
            cellIdentifier = kHeaderPageViewerCollectionViewCellIdentifier
        } else {
            cellIdentifier = kContentPageViewierCollectionViewCellIdentifier
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
                                                                         forIndexPath: indexPath)
        if let headerCell = cell as? HeaderPageViewerCollectionViewCell {
            headerCell.textLabel.text = self.dataSource.pageViewer(self, headerForItemAtIndex: indexPath.row)
            if self.indexOfCurrentPage == indexPath.row {
                headerCell.selectCellWithMultiplier(1.0, directionRight: true)
            } else {
                headerCell.deselectCellWithMultiplier(1.0, directionRight: true)
            }
        } else if let contentCell = cell as? ContentPageViewerCollectionViewCell {
            let reusableView = contentCell.contentView.subviews.first
            let pageView = self.dataSource.pageViewer(self, pageForItemAtIndex: indexPath.row, reusableView:reusableView)
            
            let addPageView = {
                pageView.translatesAutoresizingMaskIntoConstraints = false
                contentCell.contentView.addSubview(pageView)
                self.adjustConstraintsForItem(pageView, toItem: contentCell.contentView)
                pageView.setNeedsLayout()
            }
            
            if reusableView == nil {
                addPageView()
            } else if !reusableView!.isEqual(pageView) {
                reusableView?.removeFromSuperview()
                addPageView()
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.headerCollectionView {
            self.contentCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let contentCollectionViewSize = self.contentCollectionViewSize()
        var sizeForItem: CGSize
        if collectionView == self.headerCollectionView {
            let header = self.dataSource.pageViewer(self, headerForItemAtIndex: indexPath.row)
            let textSize = (header as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17.0)])
            sizeForItem = CGSizeMake(ceil(textSize.width) + round(contentCollectionViewSize.width * 0.06), 50)
        } else {
            sizeForItem = contentCollectionViewSize
        }
        
        return sizeForItem
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.contentCollectionView {
            let (indexOfPreviousPage, indexOfNextPage) = self.indexOfPreviousAndNextPage()
            
            if (indexOfNextPage < self.countOfPages &&
                indexOfPreviousPage < self.countOfPages &&
                indexOfNextPage >= 0 &&
                indexOfPreviousPage >= 0) {
                
                let indexPathOfPreviousPage = NSIndexPath(forRow: indexOfPreviousPage, inSection: 0)
                let indexPathOfNextPage = NSIndexPath(forRow: indexOfNextPage, inSection: 0)
                let attributesOfPreviousPage = self.headerCollectionView.layoutAttributesForItemAtIndexPath(indexPathOfPreviousPage)!
                let attributesOfNextPage = self.headerCollectionView.layoutAttributesForItemAtIndexPath(indexPathOfNextPage)!
                
                let selecetedMultiplierOfPage = self.selecetedMultiplierOfPage()
                let deltaContentOffsetX = (attributesOfNextPage.center.x - attributesOfPreviousPage.center.x) * selecetedMultiplierOfPage
                let contentOffsetX = (attributesOfPreviousPage.center.x - self.bounds.size.width / 2) + deltaContentOffsetX
                
                let maximumContentOffset = self.headerCollectionView.collectionViewLayout.collectionViewContentSize().width - self.headerCollectionView.bounds.size.width
                
                if 0 > contentOffsetX {
                    self.headerCollectionView.contentOffset = CGPointZero
                } else if contentOffsetX > maximumContentOffset {
                    self.headerCollectionView.contentOffset = CGPointMake(maximumContentOffset, 0)
                } else {
                    self.headerCollectionView.contentOffset = CGPointMake(contentOffsetX, 0)
                }
                
                self.indexOfCurrentPage = Int(round(scrollView.contentOffset.x / self.contentCollectionViewSize().width))
                self.selectHeaderInScrollView()
            } else {
                self.updateAllHeaderCellsExcept()
            }
            
            self.currentContentOffsetX = scrollView.contentOffset.x
        }
    }
    
    // MARK: Private Methods
    
    func contentCollectionViewSize() -> CGSize {
        return CGSizeMake(viewWillTransitionToSize.width, viewWillTransitionToSize.height - self.headerCollectionView.bounds.height)
    }
    
    func adjustConstraintsForItem(forItem: UIView, toItem: UIView) {
        let leadingConstraint = NSLayoutConstraint(item: forItem,
                                                   attribute: NSLayoutAttribute.Leading,
                                                   relatedBy: NSLayoutRelation.Equal,
                                                   toItem: toItem,
                                                   attribute: NSLayoutAttribute.Leading,
                                                   multiplier: 1,
                                                   constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: forItem,
                                                    attribute: NSLayoutAttribute.Trailing,
                                                    relatedBy: NSLayoutRelation.Equal,
                                                    toItem: toItem,
                                                    attribute: NSLayoutAttribute.Trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        let topConstraint = NSLayoutConstraint(item: forItem,
                                               attribute: NSLayoutAttribute.Top,
                                               relatedBy: NSLayoutRelation.Equal,
                                               toItem: toItem,
                                               attribute: NSLayoutAttribute.Top,
                                               multiplier: 1,
                                               constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: forItem,
                                                  attribute: NSLayoutAttribute.Bottom,
                                                  relatedBy: NSLayoutRelation.Equal,
                                                  toItem: toItem,
                                                  attribute: NSLayoutAttribute.Bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        NSLayoutConstraint.activateConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    func indexOfPreviousAndNextPage() -> (Int, Int) {
        var indexOfPreviousPage = 0
        var indexOfNextPage = 0
        let contentCollectionViewSize = self.contentCollectionViewSize()
        let indexOfCurrentPage = self.contentCollectionView.contentOffset.x / contentCollectionViewSize.width
        
        if self.isScrollingDirectionRight() {
            indexOfPreviousPage = Int(floor(indexOfCurrentPage))
            indexOfNextPage = Int(ceil(indexOfCurrentPage))
        } else {
            indexOfPreviousPage = Int(ceil(indexOfCurrentPage))
            indexOfNextPage = Int(floor(indexOfCurrentPage))
        }
        
        return (indexOfPreviousPage, indexOfNextPage)
    }
    
    func selecetedMultiplierOfPage() -> CGFloat {
        let (indexOfPreviousPage, _) = self.indexOfPreviousAndNextPage()
        return abs((self.contentCollectionView.contentOffset.x / self.contentCollectionViewSize().width) - CGFloat(indexOfPreviousPage))
    }
    
    func selectHeaderInScrollView() {
        let (indexOfPreviousPage, indexOfNextPage) = self.indexOfPreviousAndNextPage()
        
        let previousIndexPath = NSIndexPath(forRow: indexOfPreviousPage, inSection: 0)
        let nextIndexPath = NSIndexPath(forRow: indexOfNextPage, inSection: 0)
        
        if let previousCell = self.headerCollectionView.cellForItemAtIndexPath(previousIndexPath) as?HeaderPageViewerCollectionViewCell {
            if let nextCell = self.headerCollectionView.cellForItemAtIndexPath(nextIndexPath) as? HeaderPageViewerCollectionViewCell {
                
                let selecetedMultiplierOfPage = self.selecetedMultiplierOfPage()
                if (indexOfPreviousPage == indexOfNextPage) {
                    self.updateAllHeaderCellsExcept()
                } else {
                    let directionRight = self.isScrollingDirectionRight()
                    previousCell.deselectCellWithMultiplier(selecetedMultiplierOfPage, directionRight: directionRight)
                    nextCell.selectCellWithMultiplier(selecetedMultiplierOfPage, directionRight: directionRight)
                    self.updateAllHeaderCellsExcept([indexOfPreviousPage, indexOfNextPage])
                }
            }
        }
    }
    
    func updateAllHeaderCellsExcept(exceptIndexes: [Int] = []) {
        for i in (0..<self.countOfPages) {
            if !exceptIndexes.contains(i) {
                let indexPath = NSIndexPath(forRow: i, inSection: 0)
                if let cell = self.headerCollectionView.cellForItemAtIndexPath(indexPath) as? HeaderPageViewerCollectionViewCell {
                    if self.indexOfCurrentPage == indexPath.row {
                        cell.selectCellWithMultiplier(1.0, directionRight: true)
                    } else {
                        cell.deselectCellWithMultiplier(1.0, directionRight: true)
                    }
                }
            }
        }
    }
    
    func isScrollingDirectionRight() -> Bool {
        return self.currentContentOffsetX <= self.contentCollectionView.contentOffset.x
    }
}

protocol PageViewerDataSource {
    func pageViewerNumberOfPages(pageViewer: PageViewer) -> Int
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView
}
