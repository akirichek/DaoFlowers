//
//  ColorsPageView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/30/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class ColorsPageView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: ColorsPageViewDelegate?
    var spinner = RBHUD()
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    var flower: Flower!
    var colors: [Color]? {
        didSet {
            reloadData()
        }
    }
    
    // MARK: - Private Methods
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    override func awakeFromNib() {
        let nib = UINib(nibName:"ColorCollectionViewCell", bundle: nil)
         self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "ColorCollectionViewCellIdentifier")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.colors == nil {
            self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfRows = 0
        if let colors = self.colors {
            self.spinner.hideLoader()
            numberOfRows = colors.count
        } else {
            self.setNeedsLayout()
        }
        return numberOfRows
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorCollectionViewCellIdentifier", forIndexPath: indexPath) as! ColorCollectionViewCell
        cell.flower = flower
        cell.color = self.colors![indexPath.row]
    
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.colorsPageView(self, didSelectColor: self.colors![indexPath.row])
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize = self.viewWillTransitionToSize
        let columnCount: Int
        if screenSize.width < screenSize.height {
            columnCount = 2
        } else {
            columnCount = 4
        }
        
        let width = screenSize.width / CGFloat(columnCount)
        return CGSize(width: width, height: width)
    }
}

protocol ColorsPageViewDelegate: NSObjectProtocol {
    func colorsPageView(colorsPageView: ColorsPageView, didSelectColor color: Color)
}