//
//  VarietyDetailsGeneralInfoView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyDetailsGeneralInfoView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var generalInfoContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var varietyLabel: UILabel!
    @IBOutlet weak var abbrLabel: UILabel!
    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var productivityLabel: UILabel!
    @IBOutlet weak var possibleLengthLabel: UILabel!
    @IBOutlet weak var vaseLifeLabel: UILabel!
    @IBOutlet weak var breederLabel: UILabel!
    @IBOutlet weak var collectionContainerView: UIView!
    @IBOutlet weak var linkImageView: UIImageView!
    
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    var variety: Variety? {
        didSet {
            self.populateView()
        }
    }
    
    // MARK: Override Methods
    
    override func awakeFromNib() {
        
        let nib = UINib(nibName:"VarietyDetailsGeneralInfoCollectionViewCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "VarietyDetailsGeneralInfoCollectionViewCellIdentifier")
    }
    
    // MARK: Private Methods
    
    func populateView() {
        self.generalInfoContainerView.layer.cornerRadius = 5
        self.varietyLabel.text = self.variety?.name
        self.abbrLabel.text = self.variety?.abr
        self.flowerLabel.text = self.variety?.flower.name
        self.colorLabel.text = self.variety?.color.name
        if let productiveFrom = self.variety?.productiveFrom {
            self.productivityLabel.text = "\(productiveFrom) - \(self.variety!.productiveTo!)"
        }
        if let sizeFrom = self.variety?.sizeFrom {
            self.possibleLengthLabel.text = "\(sizeFrom.name) - \(self.variety!.sizeTo!.name)"
        }
        if let liveDaysFrom = self.variety?.liveDaysFrom {
            self.vaseLifeLabel.text = "\(liveDaysFrom) - \(self.variety!.liveDaysTo!)"
        }
        self.breederLabel.text = self.variety?.breeder?.name
        
        if let imageUrl = self.variety?.imageUrl {
            self.imageView.af_setImageWithURL(NSURL(string: imageUrl)!)
        } else {
            self.imageView.image = UIImage(named: "img_def_flower_rose")
        }
    
        self.collectionView.reloadData()
        
        let contentSizeHeight = self.collectionView.collectionViewLayout.collectionViewContentSize().height + self.collectionContainerView.frame.origin.y
        print(contentSizeHeight, self.collectionView.collectionViewLayout.collectionViewContentSize().height, collectionContainerView.frame.origin.y, self.scrollView.frame)
        var collectionContainerViewFrame = self.collectionContainerView.frame
        collectionContainerViewFrame.size.height = self.collectionView.collectionViewLayout.collectionViewContentSize().height
        self.collectionContainerView.frame = collectionContainerViewFrame
        
        self.linkImageView.center = CGPointMake(self.breederLabel.frame.origin.x + self.breederLabel.frame.size.width + 7, self.linkImageView.center.y)
//        self.collectionContainerViewHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize().height
        self.scrollView.contentSize = CGSizeMake(0, contentSizeHeight)
    }
    
    // MARK: - Actions
    
    @IBAction func breederLinkClicked(sender: UIButton) {
        if let url = self.variety?.breeder?.url {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 0
        if let images = self.variety?.images {
            numberOfItems = images.count
        }
        
        return numberOfItems
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VarietyDetailsGeneralInfoCollectionViewCellIdentifier", forIndexPath: indexPath) as! VarietyDetailsGeneralInfoCollectionViewCell
        cell.imageUrl = self.variety!.images![indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize = self.viewWillTransitionToSize
        let columnCount: Int
        if screenSize.width < screenSize.height {
            columnCount = 3
        } else {
            columnCount = 4
        }
        
        let width = screenSize.width / CGFloat(columnCount)
        return CGSize(width: width, height: width)
    }
}
