//
//  BaseViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/12/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    var menuButtonHandler: MenuButtonHandler!
    
    @IBAction func menuButtonClicked(sender: UIBarButtonItem) {
        self.menuButtonHandler.menuButtonClicked()
    }
}
