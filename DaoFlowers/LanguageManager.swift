//
//  LanguageManager.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/30/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

class LanguageManager: NSObject {
    
    static func getTranslationForKey(key: String) -> String {
        let bundlePath = NSBundle.mainBundle().pathForResource(self.languageCode(), ofType: "lproj")!
        let languageBundle = NSBundle(path: bundlePath)
        
        let translatedString = languageBundle?.localizedStringForKey(key, value: "", table: nil)

        if translatedString == nil {
           return NSLocalizedString(key, tableName: nil, bundle: NSBundle.mainBundle(), value: key, comment: key)
        } else {
            return translatedString!
        }
    }
    
    static func loadNibNamed(name: String!, owner: AnyObject!, options: [NSObject : AnyObject]!) -> [AnyObject]! {
        let bundlePath = NSBundle.mainBundle().pathForResource(self.languageCode(), ofType: "lproj")!
        let languageBundle = NSBundle(path: bundlePath)!
    
        return languageBundle.loadNibNamed(name, owner: owner, options: options)
    }

    static func languageCode() -> String {
        var languageCode = "en"
        if let languageRawValue = NSUserDefaults.standardUserDefaults().stringForKey(K.UserDefaultsKey.Language) {
            let language = Language(rawValue: languageRawValue)!
            languageCode = language.code()
        }
        
        return languageCode
    }
    
    static func currentLanguage() -> Language {
        var languageCode = "en"
        if let languageRawValue = NSUserDefaults.standardUserDefaults().stringForKey(K.UserDefaultsKey.Language) {
            languageCode = languageRawValue
        }
        
        let language = Language(rawValue: languageCode)!
        
        return language
    }
}

enum Language: String {
    case English = "English"
    case Russian = "Русский"
    case Spanish = "Español"
    
    func flagImageName() -> String {
        var flagImageName: String!
        switch self {
        case .English:
            flagImageName = "flag_uk"
        case .Russian:
            flagImageName = "flag_russia"
        case .Spanish:
            flagImageName = "flag_spain"
        }
        
        return flagImageName
    }
    
    func code() -> String {
        var flagImageName: String!
        switch self {
        case .English:
            flagImageName = "en"
        case .Russian:
            flagImageName = "ru"
        case .Spanish:
            flagImageName = "es"
        }
        
        return flagImageName
    }
}

func CustomLocalisedString(key: String) -> String {
    return LanguageManager.getTranslationForKey(key)
}