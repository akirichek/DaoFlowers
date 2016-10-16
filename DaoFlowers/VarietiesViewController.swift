//
//  VarietiesViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesViewController: BaseViewController {

    var flower: Flower!
    var color: Color!
    var varieties: [Variety] = []
    
    //MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiManager.fetchVarietiesByFlower(flower, color: color) { (varieties, error) in
            if let varieties = varieties {
                self.varieties = varieties
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
}
