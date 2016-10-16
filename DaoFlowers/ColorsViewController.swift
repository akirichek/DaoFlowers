//
//  ColorsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class ColorsViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var flower: Flower!
    var colors: [Color] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiManager.fetchColorsByFlower(self.flower, completion: { (colors, error) in
            self.colors = colors
            self.collectionView.reloadData()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorsCollectionViewCellIdentifier", forIndexPath: indexPath) as! ColorCollectionViewCell
        cell.color = self.colors[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let columnCount: Int
        
        if self.view.bounds.width < self.view.bounds.height {
            columnCount = 2
        } else {
            columnCount = 4
        }
        
        let width = collectionView.frame.size.width / CGFloat(columnCount)
        
        return CGSize(width: width, height: width)
    }
}
