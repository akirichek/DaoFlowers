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
    @IBOutlet weak var linkImageView: UIImageView!
    @IBOutlet weak var lastPurchaseDateLabel: UILabel!
    @IBOutlet weak var availableOnFarmsLabel: UILabel!
    @IBOutlet weak var countriesGrowsLabel: UILabel!
    @IBOutlet weak var varietyByFarmsLabel: UILabel!
    @IBOutlet weak var byFarmsFlowerLabel: UILabel!
    @IBOutlet weak var fulfillmentLabel: UILabel!
    @IBOutlet weak var boughtLastMonth: UILabel!
    @IBOutlet weak var advancedContainerView: UIView!
    @IBOutlet weak var varietyByFarmsHelpImageView: UIImageView!
    @IBOutlet weak var countriesLabel: UILabel!
    
    weak var viewController: UIViewController!
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    var variety: Variety? {
        didSet {
            self.populateView()
            self.adjustView()
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
        self.advancedContainerView.layer.cornerRadius = 5
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
        
        if variety!.availableOnFarms != nil {
            lastPurchaseDateLabel.text = variety!.lastPurchaseDate
            availableOnFarmsLabel.text = String(variety!.availableOnFarms!)
            countriesGrowsLabel.text = variety!.countries!
            
            let purchasePercent = Double(Int(round(variety!.purchasePercent! * 10000))) / 10000
            varietyByFarmsLabel.text = "\(purchasePercent) %"
            byFarmsFlowerLabel.text = "Variety by farms \(variety!.flower.name.capitalizedString):"
            let fulfillment = Double(Int(round(variety!.fulfillment! * 100))) / 100
            fulfillmentLabel.text = "\(fulfillment) %"
            
            boughtLastMonth.text = "\(variety!.invoicesDone) FB"
        }
    }
    
    func adjustView() {
        self.collectionView.reloadData()
        var collectionContainerViewFrame = self.collectionView.frame
        
        if variety!.availableOnFarms == nil {
            advancedContainerView.hidden = true
            collectionContainerViewFrame.origin.y = generalInfoContainerView.frame.origin.y + generalInfoContainerView.frame.height + 5
        } else {
            advancedContainerView.hidden = false
            collectionContainerViewFrame.origin.y = advancedContainerView.frame.origin.y + advancedContainerView.frame.height + 5
        }
        
        collectionContainerViewFrame.size.height = self.collectionView.collectionViewLayout.collectionViewContentSize().height
        self.collectionView.frame = collectionContainerViewFrame

        self.linkImageView.center = CGPointMake(self.breederLabel.frame.origin.x + self.breederLabel.frame.size.width + 8, self.linkImageView.center.y)
        
        let contentSizeHeight = self.collectionView.collectionViewLayout.collectionViewContentSize().height + self.collectionView.frame.origin.y
        self.scrollView.contentSize = CGSizeMake(0, contentSizeHeight)
        
        byFarmsFlowerLabel.sizeToFit()
        var byFarmsFlowerLabelFrame = byFarmsFlowerLabel.frame
        if byFarmsFlowerLabelFrame.width > countriesLabel.frame.width {
            byFarmsFlowerLabelFrame.size.width = countriesLabel.frame.width
        }
        byFarmsFlowerLabelFrame.origin.x = countriesLabel.frame.origin.x + countriesLabel.frame.width - byFarmsFlowerLabelFrame.width
        byFarmsFlowerLabel.frame = byFarmsFlowerLabelFrame
        varietyByFarmsHelpImageView.center = CGPointMake(byFarmsFlowerLabelFrame.origin.x - 10, varietyByFarmsHelpImageView.center.y)
    }
    
    // MARK: - Actions
    
    @IBAction func flowerImageButtonClicked(sender: UIButton) {
        if variety?.images?.count > 0 {
            viewController.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.VarietyImageViewer, sender: nil)
        }
    }
    
    @IBAction func breederLinkClicked(sender: UIButton) {
        if let url = self.variety?.breeder?.url {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    @IBAction func productivityHelpButtonCLicked(sender: UIButton) {
        let hintView = NSBundle.mainBundle().loadNibNamed("ProductivityHintView", owner: self, options: nil).first as! AHintView
        hintView.frame = self.viewController.view.bounds
        self.viewController.view.addSubview(hintView)
    }
    
    @IBAction func breederHelpButtonClicked(sender: UIButton) {
        let hintView = NSBundle.mainBundle().loadNibNamed("BreederHintView", owner: self, options: nil).first as! AHintView
        hintView.frame = self.viewController.view.bounds
        self.viewController.view.addSubview(hintView)
    }
    
    @IBAction func varietyByFarmsHelpButtonClicked(sender: UIButton) {
        let hintView = NSBundle.mainBundle().loadNibNamed("VarietyByFarmsHintView", owner: self, options: nil).first as! AHintView
        hintView.frame = self.viewController.view.bounds
        self.viewController.view.addSubview(hintView)
    }
    
    @IBAction func fulfillmentHelpButtonClicked(sender: UIButton) {
        let hintView = NSBundle.mainBundle().loadNibNamed("FulfillmentHintView", owner: self, options: nil).first as! AHintView
        hintView.frame = self.viewController.view.bounds
        self.viewController.view.addSubview(hintView)
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
        viewController.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.VarietyImageViewer, sender: indexPath.row)
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
