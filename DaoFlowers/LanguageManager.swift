//
//  LanguageManager.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/30/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

class LanguageManager: NSObject {
    func getTranslationForKey(key: String) -> String {
        let languageCode = NSUserDefaults.standardUserDefaults().stringForKey("")
        let bundlePath = NSBundle.mainBundle().pathForResource(languageCode, ofType: "lproj")!
        let languageBundle = NSBundle(path: bundlePath)
        
        let translatedString = languageBundle?.localizedStringForKey(key, value: "", table: nil)

        if translatedString == nil {
           return NSLocalizedString(key, tableName: nil, bundle: NSBundle.mainBundle(), value: key, comment: key)
        } else {
            return translatedString!
        }
    }
}