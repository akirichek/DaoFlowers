//
//  ClaimTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 4/17/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class ClaimTableViewCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var photoCountLabel: UILabel!
    @IBOutlet weak var plantationLabel: UILabel!
    @IBOutlet weak var stemsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var claim: Claim! {
        didSet {
            if userLabel != nil {
                userLabel.text = claim.client.name
                photoCountLabel.text = String(claim.photos.count)
            } else {
                photoImageView.isHidden = (claim.photos.count == 0)
            }
            
            if let plantation = claim.plantation {
                plantationLabel.text = plantation.name
            } else {
                plantationLabel.text = "???"
            }
            
            stemsLabel.text = "\(claim.stems) stems"
            descriptionLabel.text = claim.comment
            priceLabel.text = "\(claim.sum)$"
            
            switch claim.status {
            case .Sent:
                statusImageView.image = UIImage(named: "send")
                if userLabel != nil {
                    backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 205/255, alpha: 1.0)
                }
            case .Confirmed:
                statusImageView.image = UIImage(named: "checkmark")
                backgroundColor = UIColor.white
            case .InProcess:
                statusImageView.image = UIImage(named: "sand_clock")
                backgroundColor = UIColor.white
            case .LocalDraft:
                statusImageView.image = UIImage(named: "sd")
                backgroundColor = UIColor.white
            default:
                break
            }
        }
    }
}
