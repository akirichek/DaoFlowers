//
//  VarietyDetailsSimilarVarietiesView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyDetailsSimilarVarietiesView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyListLabel: UILabel!
    
    weak var delegate: VarietyDetailsSimilarVarietiesViewDelegate?
    var spinner = RBHUD()
    var viewWillTransitionToSize = UIScreen.main.bounds.size
    var varieties: [Variety]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Override Methods
    
    override func awakeFromNib() {
        let nib = UINib(nibName:"SimilarVarietyCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "SimilarVarietyCollectionViewCellIdentifier")
        emptyListLabel.text = CustomLocalisedString("Similar sorts list is empty")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.varieties == nil {
            self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 0
        if self.varieties == nil {
            self.setNeedsLayout()
        } else {
            numberOfItems = varieties!.count
            self.spinner.hideLoader()
        }
        
        self.collectionView.isHidden = (numberOfItems == 0)
        
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilarVarietyCollectionViewCellIdentifier", for: indexPath) as! SimilarVarietyCollectionViewCell
        cell.variety = varieties![indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.varietyDetailsSimilarVarietiesView(self, didSelectVariety: self.varieties![indexPath.row])
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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

protocol VarietyDetailsSimilarVarietiesViewDelegate: NSObjectProtocol {
    func varietyDetailsSimilarVarietiesView(_ varietyDetailsSimilarVarietiesView: VarietyDetailsSimilarVarietiesView, didSelectVariety variety: Variety)
}
