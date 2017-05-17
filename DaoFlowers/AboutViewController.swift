//
//  AboutViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 3/27/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var updates: [Update]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = CustomLocalisedString("About")

        let nib = UINib(nibName:"AboutTableViewHeader", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "AboutTableViewHeaderIdentifier")
        
        
        let bundlePath = Bundle.main.path(forResource: LanguageManager.languageCode(), ofType: "lproj")!
        let languageBundle = Bundle(path: bundlePath)!
        
        let updatesPath = languageBundle.path(forResource: "Updates", ofType: "plist")!
        let updatesDictionaries = NSArray(contentsOfFile: updatesPath) as! [[String: AnyObject]]
        
        updates = []
        for updateDictionary in updatesDictionaries {
            let update = Update(dictionary: updateDictionary)
            updates.append(update)
        }
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return updates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updates[section].news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutTableViewCellIdentifier", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.text = updates[indexPath.section].news[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow = tableView.rowHeight
        
        if isPortraitOrientation() {
            let labelHeight: CGFloat = 20
            let heightForText = Utils.heightForText(updates[indexPath.section].news[indexPath.row],
                                                    havingWidth: 270,
                                                    andFont: UIFont.systemFont(ofSize: 13))
            
            if heightForText > labelHeight {
                heightForRow += heightForText - labelHeight
            }
        }
        
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AboutTableViewHeaderIdentifier") as! AboutTableViewHeader
        headerView.update = updates[section]
        return headerView
    }

}
