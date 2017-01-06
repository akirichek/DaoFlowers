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
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func overlayViewClicked(_ sender: UITapGestureRecognizer) {
        print(sender.location(in: contentView))
        
        if !contentView.bounds.contains(sender.location(in: contentView)) {
            self.removeFromSuperview()
        }
    }
}
