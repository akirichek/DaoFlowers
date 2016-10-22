//
//  PageViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit
import RBHUD

class PageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var headerCollectionView: UICollectionView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    var flowers: [Flower] = []
    var currentFlower: Flower!
    var colors: [Color] = []
    var currentContentOffsetX: CGFloat = 0.0
    var indexOfCurrentPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LGHorizontalLinearFlowLayout.configureLayout(collectionView: self.contentCollectionView, itemSize: CGSizeMake(100, 100), minimumLineSpacing: 0)
        
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchColorsByFlower(self.currentFlower, completion: { (colors, error) in
            RBHUD.sharedInstance.hideLoader()
            if let colors = colors {
                self.colors = colors
                self.contentCollectionView.reloadData()
            } else {
                Utils.showError(error!, inViewController: self)
            }
        })
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.headerCollectionView.collectionViewLayout.invalidateLayout()
        self.contentCollectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.flowers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cellIdentifier: String
        
        if collectionView == self.headerCollectionView {
            cellIdentifier = "HeaderPageViewerCollectionViewCellIdentifier"
        } else {
            cellIdentifier = "ContentPageViewierCollectionViewCellIdentifier"
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
                                                                         forIndexPath: indexPath)
        if let headerCell = cell as? HeaderPageViewerCollectionViewCell {
            headerCell.textLabel.text = self.flowers[indexPath.row].name
            if self.indexOfCurrentPage == indexPath.row {
                headerCell.selectCellWithMultiplier(1.0, directionRight: true)
            } else {
                headerCell.deselectCellWithMultiplier(1.0, directionRight: true)
            }
        } else if let contentCell = cell as? ColorsCollectionViewCell {
            contentCell.colors = self.colors
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
        var size: CGSize
        if collectionView == self.headerCollectionView {
            let flower = self.flowers[indexPath.row]
            let textSize = (flower.name as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17.0)])
            size = CGSizeMake(ceil(textSize.width) + round(collectionView.bounds.width * 0.06), 50)
        } else {
            size = collectionView.frame.size
        }
        return size
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.contentCollectionView {
            let (indexOfPreviousPage, indexOfNextPage) = self.indexOfPreviousAndNextPageInScrollView(scrollView)
            
            if (indexOfNextPage < self.flowers.count &&
               indexOfPreviousPage < self.flowers.count &&
               indexOfNextPage >= 0 &&
               indexOfPreviousPage >= 0) {
                
                let indexPathOfPreviousPage = NSIndexPath(forRow: indexOfPreviousPage, inSection: 0)
                let indexPathOfNextPage = NSIndexPath(forRow: indexOfNextPage, inSection: 0)
                let attributesOfPreviousPage = self.headerCollectionView.layoutAttributesForItemAtIndexPath(indexPathOfPreviousPage)!
                let attributesOfNextPage = self.headerCollectionView.layoutAttributesForItemAtIndexPath(indexPathOfNextPage)!
                
                let selecetedMultiplierOfPage = self.selecetedMultiplierOfPageInScrollView(scrollView)
                let deltaContentOffsetX = (attributesOfNextPage.center.x - attributesOfPreviousPage.center.x) * selecetedMultiplierOfPage
                let contentOffsetX = (attributesOfPreviousPage.center.x - self.view.bounds.size.width / 2) + deltaContentOffsetX
                
                let maximumContentOffset = self.headerCollectionView.contentSize.width - self.headerCollectionView.bounds.size.width
                
                if 0 > contentOffsetX {
                    self.headerCollectionView.contentOffset = CGPointZero
                } else if contentOffsetX > maximumContentOffset {
                    self.headerCollectionView.contentOffset = CGPointMake(maximumContentOffset, 0)
                } else {
                    self.headerCollectionView.contentOffset = CGPointMake(contentOffsetX, 0)
                }
                
                let indexOfCurrentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
                self.selectHeaderInScrollView(scrollView)
                self.indexOfCurrentPage = indexOfCurrentPage
            }
            
            self.currentContentOffsetX = scrollView.contentOffset.x
        }
    }
    
    // MARK: Private Methods
    
    func indexOfPreviousAndNextPageInScrollView(scrollView: UIScrollView) -> (Int, Int) {
        var indexOfPreviousPage = 0
        var indexOfNextPage = 0
        let indexOfCurrentPage = scrollView.contentOffset.x / scrollView.frame.size.width
        
        if self.isScrollingDirectionRight(scrollView) {
            indexOfPreviousPage = Int(floor(indexOfCurrentPage))
            indexOfNextPage = Int(ceil(indexOfCurrentPage))
        } else {
            indexOfPreviousPage = Int(ceil(indexOfCurrentPage))
            indexOfNextPage = Int(floor(indexOfCurrentPage))
        }
        
        return (indexOfPreviousPage, indexOfNextPage)
    }
    
    func selecetedMultiplierOfPageInScrollView(scrollView: UIScrollView) -> CGFloat {
        let (indexOfPreviousPage, _) = self.indexOfPreviousAndNextPageInScrollView(scrollView)
        return abs((scrollView.contentOffset.x / scrollView.frame.size.width) - CGFloat(indexOfPreviousPage))
    }
    
    func selectHeaderInScrollView(scrollView: UIScrollView) {
        let (indexOfPreviousPage, indexOfNextPage) = self.indexOfPreviousAndNextPageInScrollView(scrollView)
        
        let previousIndexPath = NSIndexPath(forRow: indexOfPreviousPage, inSection: 0)
        let nextIndexPath = NSIndexPath(forRow: indexOfNextPage, inSection: 0)
        
        if let previousCell = self.headerCollectionView.cellForItemAtIndexPath(previousIndexPath) as?HeaderPageViewerCollectionViewCell {
            if let nextCell = self.headerCollectionView.cellForItemAtIndexPath(nextIndexPath) as? HeaderPageViewerCollectionViewCell {
                
                let selecetedMultiplierOfPage = self.selecetedMultiplierOfPageInScrollView(scrollView)
                if (indexOfPreviousPage == indexOfNextPage) {
                    self.updateAllHeaderCellsExcept([indexOfNextPage])
                } else {
                    let directionRight = self.isScrollingDirectionRight(scrollView)
                    previousCell.deselectCellWithMultiplier(selecetedMultiplierOfPage, directionRight: directionRight)
                    nextCell.selectCellWithMultiplier(selecetedMultiplierOfPage, directionRight: directionRight)
                    self.updateAllHeaderCellsExcept([indexOfPreviousPage, indexOfNextPage])
                }
            }
        }
    }
    
    func updateAllHeaderCellsExcept(exceptIndexes: [Int]) {
        for i in (0..<self.flowers.count) {
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
    
    func isScrollingDirectionRight(scrollView: UIScrollView) -> Bool {
        return self.currentContentOffsetX <= scrollView.contentOffset.x
    }
}
