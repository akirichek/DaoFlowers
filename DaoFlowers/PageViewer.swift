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
    
    weak var dataSource: PageViewerDataSource!
    weak var delegate: PageViewerDelegate?
    var countOfPages: Int {
        get {
            return self.dataSource.pageViewerNumberOfPages(self)
        }
    }
    var currentContentOffsetX: CGFloat = 0.0
    var scrollingLocked = false
    var viewWillTransitionToSize: CGSize! {
        didSet {
            scrollingLocked = true
        }
    }
    var indexOfCurrentPage: Int = 0 {
        didSet {
            delegate?.pageViewer(self, didSelectPageAtIndex: indexOfCurrentPage)
        }
    }
    
    // MARK: Public Methods
    
    func reloadData() {
        self.headerCollectionView.reloadData()
        self.contentCollectionView.reloadData()
        let contentCollectionViewSize = self.contentCollectionViewSize()
        let currentContentOffsetX = CGFloat(self.indexOfCurrentPage) * contentCollectionViewSize.width
        self.contentCollectionView.setContentOffset(CGPoint(x: currentContentOffsetX, y: 0), animated: true)
    }
    
    func pageAtIndex(_ index: Int) -> UIView? {
        let cell = self.contentCollectionView.cellForItem(at: IndexPath(row: index, section: 0))
        return cell?.contentView.subviews.first
    }
    
    func selectPageAtIndex(_ index: Int) {
        scrollingLocked = false
        let contentCollectionViewSize = self.contentCollectionViewSize()
        let currentContentOffsetX = CGFloat(index) * contentCollectionViewSize.width
        self.contentCollectionView.setContentOffset(CGPoint(x: currentContentOffsetX, y: 0), animated: false)
    }
    
    // MARK: Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        PageViewerFlowLayout.configureLayout(self.contentCollectionView)
        
        let headerCellNib = UINib(nibName:"HeaderPageViewerCollectionViewCell", bundle: nil)
        self.headerCollectionView.register(headerCellNib, forCellWithReuseIdentifier: kHeaderPageViewerCollectionViewCellIdentifier)
        let contentCellNib = UINib(nibName:"ContentPageViewerCollectionViewCell", bundle: nil)
        self.contentCollectionView.register(contentCellNib, forCellWithReuseIdentifier: kContentPageViewierCollectionViewCellIdentifier)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.pageViewerNumberOfPages(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellIdentifier: String
        
        if collectionView == self.headerCollectionView {
            cellIdentifier = kHeaderPageViewerCollectionViewCellIdentifier
        } else {
            cellIdentifier = kContentPageViewierCollectionViewCellIdentifier
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                                         for: indexPath)
        if let headerCell = cell as? HeaderPageViewerCollectionViewCell {
            headerCell.textLabel.text = self.dataSource.pageViewer(self, headerForItemAtIndex: indexPath.row).uppercased()
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

        scrollingLocked = false
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.headerCollectionView {
            self.contentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentCollectionViewSize = self.contentCollectionViewSize()
        var sizeForItem: CGSize
        if collectionView == self.headerCollectionView {
            let header = self.dataSource.pageViewer(self, headerForItemAtIndex: indexPath.row).uppercased()
            let textSize = (header as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13.0)])
            sizeForItem = CGSize(width: ceil(textSize.width) + 20, height: self.headerCollectionView.bounds.height)
        } else {
            sizeForItem = contentCollectionViewSize
        }
        
        return sizeForItem
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollingLocked else {
            return
        }
        
        if scrollView == self.contentCollectionView {
            let (indexOfPreviousPage, indexOfNextPage) = self.indexOfPreviousAndNextPage()
            
            if (indexOfNextPage < self.countOfPages &&
                indexOfPreviousPage < self.countOfPages &&
                indexOfNextPage >= 0 &&
                indexOfPreviousPage >= 0) {
                
                let indexPathOfPreviousPage = IndexPath(row: indexOfPreviousPage, section: 0)
                let indexPathOfNextPage = IndexPath(row: indexOfNextPage, section: 0)
                let attributesOfPreviousPage = self.headerCollectionView.layoutAttributesForItem(at: indexPathOfPreviousPage)!
                let attributesOfNextPage = self.headerCollectionView.layoutAttributesForItem(at: indexPathOfNextPage)!
                
                let selecetedMultiplierOfPage = self.selecetedMultiplierOfPage()
                let deltaContentOffsetX = (attributesOfNextPage.center.x - attributesOfPreviousPage.center.x) * selecetedMultiplierOfPage
                let contentOffsetX = (attributesOfPreviousPage.center.x - self.bounds.size.width / 2) + deltaContentOffsetX
                
                var maximumContentOffset = self.headerCollectionView.collectionViewLayout.collectionViewContentSize.width - self.headerCollectionView.bounds.size.width
                if maximumContentOffset < 0 {
                    maximumContentOffset = 0
                }
                
                if 0 > contentOffsetX {
                    self.headerCollectionView.contentOffset = CGPoint.zero
                } else if contentOffsetX > maximumContentOffset {
                    self.headerCollectionView.contentOffset = CGPoint(x: maximumContentOffset, y: 0)
                } else {
                    self.headerCollectionView.contentOffset = CGPoint(x: contentOffsetX, y: 0)
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
        return CGSize(width: viewWillTransitionToSize.width, height: viewWillTransitionToSize.height - self.headerCollectionView.bounds.height)
    }
    
    func adjustConstraintsForItem(_ forItem: UIView, toItem: UIView) {
        let leadingConstraint = NSLayoutConstraint(item: forItem,
                                                   attribute: NSLayoutAttribute.leading,
                                                   relatedBy: NSLayoutRelation.equal,
                                                   toItem: toItem,
                                                   attribute: NSLayoutAttribute.leading,
                                                   multiplier: 1,
                                                   constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: forItem,
                                                    attribute: NSLayoutAttribute.trailing,
                                                    relatedBy: NSLayoutRelation.equal,
                                                    toItem: toItem,
                                                    attribute: NSLayoutAttribute.trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        let topConstraint = NSLayoutConstraint(item: forItem,
                                               attribute: NSLayoutAttribute.top,
                                               relatedBy: NSLayoutRelation.equal,
                                               toItem: toItem,
                                               attribute: NSLayoutAttribute.top,
                                               multiplier: 1,
                                               constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: forItem,
                                                  attribute: NSLayoutAttribute.bottom,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: toItem,
                                                  attribute: NSLayoutAttribute.bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
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
        
        let previousIndexPath = IndexPath(row: indexOfPreviousPage, section: 0)
        let nextIndexPath = IndexPath(row: indexOfNextPage, section: 0)
        
        if let previousCell = self.headerCollectionView.cellForItem(at: previousIndexPath) as?HeaderPageViewerCollectionViewCell {
            if let nextCell = self.headerCollectionView.cellForItem(at: nextIndexPath) as? HeaderPageViewerCollectionViewCell {
                
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
    
    func updateAllHeaderCellsExcept(_ exceptIndexes: [Int] = []) {
        for i in (0..<self.countOfPages) {
            if !exceptIndexes.contains(i) {
                let indexPath = IndexPath(row: i, section: 0)
                if let cell = self.headerCollectionView.cellForItem(at: indexPath) as? HeaderPageViewerCollectionViewCell {
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

protocol PageViewerDataSource: NSObjectProtocol {
    func pageViewerNumberOfPages(_ pageViewer: PageViewer) -> Int
    func pageViewer(_ pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String
    func pageViewer(_ pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView
}

protocol PageViewerDelegate: NSObjectProtocol {
    func pageViewer(_ pageViewer: PageViewer, didSelectPageAtIndex index: Int)
}
