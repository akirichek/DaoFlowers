//
//  Utils.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class Utils: NSObject {
    
    static func showError(error: NSError, inViewController viewController: UIViewController)  {
        self.showErrorWithMessage(error.localizedDescription, inViewController: viewController)
    }
    
    static func showErrorWithMessage(message: String, inViewController viewController: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let okAlertAction = UIAlertAction(title: "OK", style: .Default) { alertAction in
            viewController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(okAlertAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
}
