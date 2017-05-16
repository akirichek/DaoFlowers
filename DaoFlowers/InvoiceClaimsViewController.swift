//
//  InvoiceClaimsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 5/11/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceClaimsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var langClaimsLabel: UILabel!
    
    var invoice: Document!
    var invoiceDetails: InvoiceDetails!
    var claims: [Claim] = []
    weak var delegate: InvoiceClaimsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        langClaimsLabel.text = CustomLocalisedString("Claims")
        fetchInvoiceDetails()
    }
    
    func fetchInvoiceDetails() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchInvoiceDetails(invoice.id, clientId: invoice.clientId, user: User.currentUser()!) { (invoiceDetails, error) in
            RBHUD.sharedInstance.hideLoader()
            if let invoiceDetails = invoiceDetails {
                self.invoiceDetails = invoiceDetails
                self.adjustView()
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func adjustView() {
        let localClaims = DataManager.fetchClaims(forUser: User.currentUser()!)        
        var claims: [Claim] = localClaims.filter({ $0.invoiceId == invoice.id })
        for claim in invoice.claims {
            var newClaim = claim
            newClaim.plantation = invoiceDetails.plantationById(claim.plantationId)
            claims.append(newClaim)
        }
        self.claims = claims
        tableView.reloadData()
    }
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return claims.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClaimTableViewCellIdentifier", for: indexPath) as! ClaimTableViewCell
        cell.claim = claims[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.invoiceClaimsViewController(self, didSelectClaim: claims[indexPath.row])
    }
}

protocol InvoiceClaimsViewControllerDelegate: NSObjectProtocol {
    func invoiceClaimsViewController(_ invoiceClaimsViewController: InvoiceClaimsViewController, didSelectClaim claim: Claim)
}
