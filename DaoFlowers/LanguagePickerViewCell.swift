//
//  LanguagePickerViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/30/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class LanguagePickerViewCell: UIView {
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    var language: Language! {
        didSet {
           populateView()
        }
    }
    
    func populateView() {
        flagImageView.image = UIImage(named: language.flagImageName())
        textLabel.text = language.rawValue
    }
}
