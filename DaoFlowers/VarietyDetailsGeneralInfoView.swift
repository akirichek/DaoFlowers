//
//  VarietyDetailsGeneralInfoView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    var viewWillTransitionToSize = UIScreen.main.bounds.size
    var variety: Variety? {
        didSet {
            self.populateView()
            self.adjustView()
        }
    }
    
    // MARK: Override Methods
    
    override func awakeFromNib() {
        let nib = UINib(nibName:"VarietyDetailsGeneralInfoCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "VarietyDetailsGeneralInfoCollectionViewCellIdentifier")
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
        
        if let breeder = self.variety?.breeder {
            self.breederLabel.text = breeder.name
        } else {
            self.breederLabel.text = "-"
        }
        
        self.imageView.image = UIImage(named: self.variety!.flower.defaultImage)
        if let imageUrl = self.variety?.imageUrl {
            self.imageView.af_setImage(withURL: URL(string: imageUrl)!)
        }
        
        if variety!.availableOnFarms != nil {
            lastPurchaseDateLabel.text = variety!.lastPurchaseDate
            availableOnFarmsLabel.text = String(variety!.availableOnFarms!)
            countriesGrowsLabel.text = variety!.countries!
            
            if var purchasePercent = variety!.purchasePercent {
                purchasePercent = Double(Int(round(purchasePercent * 10000))) / 10000
                varietyByFarmsLabel.text = "\(purchasePercent) %"
            }
            
            byFarmsFlowerLabel.text = CustomLocalisedString("Variety by farms") + " " + "\(variety!.flower.name.capitalized):"
            if var fulfillment = variety!.fulfillment {
                fulfillment = Double(Int(round(fulfillment * 100))) / 100
                fulfillmentLabel.text = "\(fulfillment) %"
            }
            boughtLastMonth.text = "\(variety!.invoicesDone) FB"
        }
    }
    
    func adjustView() {
        self.collectionView.reloadData()
        var collectionContainerViewFrame = self.collectionView.frame
        
        if variety!.availableOnFarms == nil {
            advancedContainerView.isHidden = true
            collectionContainerViewFrame.origin.y = generalInfoContainerView.frame.origin.y + generalInfoContainerView.frame.height + 5
        } else {
            advancedContainerView.isHidden = false
            collectionContainerViewFrame.origin.y = advancedContainerView.frame.origin.y + advancedContainerView.frame.height + 5
        }
        
        collectionContainerViewFrame.size.height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        self.collectionView.frame = collectionContainerViewFrame

        let contentSizeHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height + self.collectionView.frame.origin.y
        self.scrollView.contentSize = CGSize(width: 0, height: contentSizeHeight)
        
        byFarmsFlowerLabel.sizeToFit()
        var byFarmsFlowerLabelFrame = byFarmsFlowerLabel.frame
        if byFarmsFlowerLabelFrame.width > countriesLabel.frame.width {
            byFarmsFlowerLabelFrame.size.width = countriesLabel.frame.width
        }
        byFarmsFlowerLabelFrame.origin.x = countriesLabel.frame.origin.x + countriesLabel.frame.width - byFarmsFlowerLabelFrame.width
        byFarmsFlowerLabel.frame = byFarmsFlowerLabelFrame
        varietyByFarmsHelpImageView.center = CGPoint(x: byFarmsFlowerLabelFrame.origin.x - 10, y: varietyByFarmsHelpImageView.center.y)
        
        self.linkImageView.center = CGPoint(x: self.breederLabel.frame.origin.x + self.breederLabel.frame.size.width + 8, y: self.linkImageView.center.y)
    }
    
    // MARK: - Actions
    
    @IBAction func flowerImageButtonClicked(_ sender: UIButton) {
        if variety?.images?.count > 0 {
            viewController.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.VarietyImageViewer, sender: nil)
        }
    }
    
    @IBAction func breederLinkClicked(_ sender: UIButton) {
        if let url = self.variety?.breeder?.url {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @IBAction func productivityHelpButtonCLicked(_ sender: UIButton) {
        let hintView = LanguageManager.loadNibNamed("ProductivityHintView", owner: self, options: nil).first as! AHintView
        hintView.frame = self.viewController.view.bounds
        self.viewController.view.addSubview(hintView)
    }
    
    @IBAction func breederHelpButtonClicked(_ sender: UIButton) {
        let hintView = LanguageManager.loadNibNamed("BreederHintView", owner: self, options: nil).first as! AHintView
        hintView.frame = self.viewController.view.bounds
        self.viewController.view.addSubview(hintView)
    }
    
    @IBAction func varietyByFarmsHelpButtonClicked(_ sender: UIButton) {
        let hintView = LanguageManager.loadNibNamed("VarietyByFarmsHintView", owner: self, options: nil).first as! AHintView
        hintView.frame = self.viewController.view.bounds
        self.viewController.view.addSubview(hintView)
    }
    
    @IBAction func fulfillmentHelpButtonClicked(_ sender: UIButton) {
        let hintView = LanguageManager.loadNibNamed("FulfillmentHintView", owner: self, options: nil).first as! AHintView
        hintView.frame = self.viewController.view.bounds
        self.viewController.view.addSubview(hintView)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 0
        if let images = self.variety?.images {
            numberOfItems = images.count
        }
        
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VarietyDetailsGeneralInfoCollectionViewCellIdentifier", for: indexPath) as! VarietyDetailsGeneralInfoCollectionViewCell
        cell.image = self.variety!.images![indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewController.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.VarietyImageViewer, sender: indexPath.row)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
