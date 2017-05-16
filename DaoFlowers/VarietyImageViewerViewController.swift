//
//  VarietyImageViewerViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/29/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyImageViewerViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectedPageLabel: UILabel!
    
    var images: [Variety.Image]!
    var photos: [Photo] = []
    var indexOfCurrentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adjustSelectedPageLabel()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
        scrollToCurrentPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToCurrentPage()
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    func scrollToCurrentPage() {
        let currentContentOffsetX = CGFloat(self.indexOfCurrentPage) * viewWillTransitionToSize.width
        self.collectionView.setContentOffset(CGPoint(x: currentContentOffsetX, y: 0), animated: true)
    }
    
    func adjustSelectedPageLabel() {
        if photos.count > 0 {
            selectedPageLabel.text = "\(indexOfCurrentPage + 1) from \(photos.count)"
        } else {
            selectedPageLabel.text = "\(indexOfCurrentPage + 1) from \(images.count)"
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 0
        if photos.count > 0 {
            numberOfItems = photos.count
        } else {
            numberOfItems = images.count
        }
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VarietyImageCellIdentifier", for: indexPath) as! VarietyImageCollectionViewCell
        
        if photos.count > 0 {
            cell.photo = photos[indexPath.row]
        } else {
            cell.image = images[indexPath.row]
        }

        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return self.viewWillTransitionToSize
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.indexOfCurrentPage = Int(round(collectionView.contentOffset.x / collectionView.frame.width))
        adjustSelectedPageLabel()
    }
}
