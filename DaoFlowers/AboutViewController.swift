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
    var updates: [Update] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName:"AboutTableViewHeader", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "AboutTableViewHeaderIdentifier")
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
        cell.textLabel?.text = updates[indexPath.section].news[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AboutTableViewHeaderIdentifier") as! AboutTableViewHeader

        
        return headerView
    }

}
