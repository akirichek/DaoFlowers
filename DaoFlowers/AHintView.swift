//
//  AHintView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/12/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class AHintView: UIView {

    @IBOutlet weak var contentView: UIView!

    
    // MARK: Actions
    
    @IBAction func okButtonClicked(sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func overlayViewClicked(sender: UITapGestureRecognizer) {
        print(sender.locationInView(contentView))
        
        if !CGRectContainsPoint(contentView.bounds, sender.locationInView(contentView)) {
            self.removeFromSuperview()
        }
    }
}
