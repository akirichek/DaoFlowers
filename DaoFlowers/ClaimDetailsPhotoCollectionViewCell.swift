//
//  ClaimDetailsPhotoCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 4/21/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class ClaimDetailsPhotoCollectionViewCell: UICollectionViewCell {
    weak var delegate: ClaimDetailsPhotoCollectionViewCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removeButtonContainerView: UIView!
    
    var photo: Photo! {
        didSet {
            imageView.image = photo.image
            if let url = photo.url {
                imageView.af_setImage(withURL: URL(string: url)!)
            }
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        delegate?.claimDetailsPhotoCollectionViewCell(self, didClosePhoto: photo)
    }
}

protocol ClaimDetailsPhotoCollectionViewCellDelegate: NSObjectProtocol {
    func claimDetailsPhotoCollectionViewCell(_ cell: ClaimDetailsPhotoCollectionViewCell, didClosePhoto photo: Photo)
}
