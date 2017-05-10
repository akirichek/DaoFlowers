//
//  ClaimDetailsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 4/20/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class ClaimDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, ClaimDetailsPhotoCollectionViewCellDelegate, AddClaimViewControllerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var photosContainerView: UIView!
    @IBOutlet weak var invoiceDetailsContainerView: UIView!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet var cornerRadiusViews: [UIView]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var invoiceDateLabel: UILabel!
    @IBOutlet weak var clientHeaderLabel: UILabel!
    
    @IBOutlet weak var awbLabel: UILabel!
    @IBOutlet weak var plantationLabel: UILabel!
    @IBOutlet weak var piecesLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var photosCountLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    var claim: Claim!
    var invoice: Document!
    var invoiceDetails: InvoiceDetails!
    var invoiceDetailsHead: InvoiceDetails.Head!
    var claimsSubjects: [Claim.Subject]!
    var subjectPickerView: UIPickerView!
    var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var nib = UINib(nibName:"ClaimDetailsInvoiceRowTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ClaimDetailsInvoiceRowTableViewCellIdentifier")
        
        nib = UINib(nibName:"ClaimDetailsTotalTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ClaimDetailsTotalTableViewCellIdentifier")
        
        nib = UINib(nibName:"ClaimDetailsTotalInvoiceRowTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ClaimDetailsTotalInvoiceRowTableViewCellIdentifier")
        
        nib = UINib(nibName:"ClaimDetailsTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ClaimDetailsTableViewCellIdentifier")
        
        cornerRadiusViews.forEach({ $0.layer.cornerRadius = 3 })
        headerView.layer.cornerRadius = 3
        
        subjectPickerView = createPickerViewForTextField(subjectTextField)
        
        
        if claim == nil {
            claim = Claim(user: User.currentUser()!, date: Date())
        }
        
        fetchClaimSubjects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        
        if let addClaimViewController = destinationViewController as? AddClaimViewController {
            let invoiceDetailsRow = sender as! InvoiceDetails.Row
            addClaimViewController.delegate = self
            addClaimViewController.invoiceDetails = invoiceDetails
            addClaimViewController.invoiceDetailsHead = invoiceDetailsHead
            addClaimViewController.invoiceDetailsRow = invoiceDetailsRow
            addClaimViewController.claimInvoiceRow = claim.invoceRows.first(where: { $0.rowId == invoiceDetailsRow.id })
        }
    }
    
    // MARK: - Private Methods
    
    func populateView() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: invoice.date as Date)
        let locale = Locale(identifier: LanguageManager.languageCode())
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "EEE"
        let weekdayString = dateFormatter.string(from: invoice.date as Date).lowercased()
        invoiceDateLabel.text = "\(dateString) [\(weekdayString)]"
        clientHeaderLabel.text = invoice.label
        clientLabel.text = invoice.label

        awbLabel.text = invoiceDetailsHead.awb
        let plantation = invoiceDetails.plantationById(invoiceDetailsHead.plantationId)!
        if plantation.name == plantation.brand {
            plantationLabel.text = plantation.name
        } else {
            let planNameFontAttr = [NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)]
            let plantationString = "\(plantation.name) [\(plantation.brand)]"
            let plantationAttrString = NSMutableAttributedString(string: plantationString, attributes: planNameFontAttr)
            let range = NSRange(location: plantation.name.characters.count + 1, length: plantation.brand.characters.count + 2)
            plantationAttrString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12), range: range)
            plantationLabel.attributedText = plantationAttrString
        }
        
        let country = invoiceDetails.countryById(invoiceDetailsHead.countryId)!
        countryLabel.text = country.abr
        piecesLabel.text = invoiceDetailsHead.pieces.replacingOccurrences(of: ";", with: " ")
        commentTextView.text = claim.comment
        
        populateSubjectTextField()
    }
    
    func populateSubjectTextField() {
        if let subjectId = claim.subjectId {
            let index = claimsSubjects.index(where: { $0.id == subjectId })!
            let subject = claimsSubjects[index]
            subjectTextField.text = subject.name
        } else {
            subjectTextField.text = "--------"
        }
    }
    
    func adjustView() {
        tableView.reloadData()
        tableView.frame.size.height = tableView.contentSize.height
        invoiceDetailsContainerView.frame.size.height = tableView.frame.origin.y + tableView.frame.height
        photosContainerView.frame.origin.y = invoiceDetailsContainerView.frame.origin.y + invoiceDetailsContainerView.frame.height + 3
        photosCollectionView.frame.origin.y = photosContainerView.frame.origin.y + photosContainerView.frame.height + 3
        photosCollectionView.reloadData()
        photosCollectionView.frame.size.height = photosCollectionView.collectionViewLayout.collectionViewContentSize.height
        scrollView.contentSize = CGSize(width: 320, height: photosCollectionView.frame.origin.y + photosCollectionView.frame.height + 3)
        
        photosCountLabel.text = "\(claim!.photos.count)/100"
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: commentTextView,
                                         action: #selector(resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        commentTextView.inputAccessoryView = toolbar
    }
    
    func fetchInvoiceDetails() {
        ApiManager.fetchInvoices(User.currentUser()!) { (invoices, error) in
            if let invoices = invoices {
                self.invoice = invoices.first(where: { $0.id == self.claim.invoiceDetailsHead!.invoiceId })
                ApiManager.fetchInvoiceDetails(self.invoice, user: User.currentUser()!) { (invoiceDetails, error) in
                    RBHUD.sharedInstance.hideLoader()
                    if let invoiceDetails = invoiceDetails {
                        self.invoiceDetails = invoiceDetails
                        self.invoiceDetailsHead = invoiceDetails.heads.first(where: { $0.id == self.claim.invoiceDetailsHead!.id })
                        self.populateView()
                        self.adjustView()
                    } else {
                        Utils.showError(error!, inViewController: self)
                    }
                }
            } else {
                RBHUD.sharedInstance.hideLoader()
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func fetchClaimSubjects() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchClaimSubjects(User.currentUser()!) { (claimsSubjects, error) in
            if let claimsSubjects = claimsSubjects {
                self.claimsSubjects = claimsSubjects
                if self.claim.id != nil {
                    self.fetchClaimDetails()
                } else if self.invoice == nil {
                    self.fetchInvoiceDetails()
                } else {
                    RBHUD.sharedInstance.hideLoader()
                }
            } else {
                RBHUD.sharedInstance.hideLoader()
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func fetchClaimDetails() {
        ApiManager.fetchClaimDetailsForClaim(self.claim, user: User.currentUser()!, completion: { (claim, invoice, invoiceDetails, invoiceDetailsHead, error) in
            RBHUD.sharedInstance.hideLoader()
            if let error = error {
                Utils.showError(error, inViewController: self)
            } else {
                self.claim = claim
                self.invoice = invoice
                self.invoiceDetails = invoiceDetails
                self.invoiceDetailsHead = invoiceDetailsHead
                self.populateView()
                self.adjustView()
            }
        })
    }
    
    func createPickerViewForTextField(_ textField: UITextField) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: self,
                                         action: #selector(ClaimDetailsViewController.subjectPickerSelected))
        toolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        
        return pickerView
    }
    
    func subjectPickerSelected() {
        let row = subjectPickerView.selectedRow(inComponent: 0)
        if row > 0 {
            let subject = claimsSubjects[row - 1]
            claim.subjectId = subject.id
        } else {
            claim.subjectId = nil
        }
        
        subjectTextField.resignFirstResponder()
        populateSubjectTextField()
    }
    
    func sendClaim() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.saveClaim(self.claim, user: User.currentUser()!) { (error) in
            RBHUD.sharedInstance.hideLoader()
            if let error = error {
                Utils.showError(error, inViewController: self)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
                if self.claim.objectID != nil {
                    DataManager.removeClaim(self.claim)
                }
            }
        }
    }
    
    func saveToLocalDraft() {
        self.claim.plantation = self.invoiceDetails.plantationById(self.invoiceDetailsHead.plantationId)!
        DataManager.saveClaim(self.claim)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func addPhotoButtonClicked(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .savedPhotosAlbum
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let actionSheet = UIAlertController(title: "Adding Photo",
                                                message: "What source would you like to use to add photo?",
                                                preferredStyle: .actionSheet)
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
                imagePickerController.sourceType = .savedPhotosAlbum
                self.present(imagePickerController, animated: true, completion: nil)
            }
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alertAction) in
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheet.addAction(photoLibraryAction)
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(cancelAction)
            
            present(actionSheet, animated: true, completion: nil)
        } else {
            imagePickerController.sourceType = .savedPhotosAlbum
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func subjectTextFieldClicked(_ sender: UITextField) {
        if let subjectId = claim.subjectId {
            let row = claimsSubjects.index(where: { $0.id == subjectId })!
            subjectPickerView.selectRow(row + 1, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        claim.invoiceDetailsHead = self.invoiceDetailsHead
        claim.comment = commentTextView.text
        let alertController = UIAlertController(title: "Saving Claim",
                                                message: "How would you like to save the claim?",
                                                preferredStyle: .alert)
        let localDraftAction = UIAlertAction(title: "Local draft", style: .default) { (action) in
            self.saveToLocalDraft()
        }
        let sendAction = UIAlertAction(title: "Send to processing", style: .default) { (action) in
            self.sendClaim()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(localDraftAction)
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func removeButtonClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Deleting claim",
                                                message: "Are you sure you want to delete the claim?",
                                                preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in
            if self.claim.objectID != nil {
                DataManager.removeClaim(self.claim)
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                
            }
        }
        let noAction = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if invoiceDetailsHead != nil {
            numberOfRows = invoiceDetailsHead.rows.count + 1
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String
        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            if claim.invoceRows.count > 0 {
                cellIdentifier = "ClaimDetailsTotalInvoiceRowTableViewCellIdentifier"
            } else {
                cellIdentifier = "ClaimDetailsTotalTableViewCellIdentifier"
            }
        } else {
            let invoiceDetailsHeadRow = invoiceDetailsHead.rows[indexPath.row]
            if claim.invoceRows.index(where: { $0.rowId == invoiceDetailsHeadRow.id }) != nil {
                cellIdentifier = "ClaimDetailsInvoiceRowTableViewCellIdentifier"
            } else {
                cellIdentifier = "ClaimDetailsTableViewCellIdentifier"
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ClaimDetailsTableViewCell
        cell.invoiceDetails = invoiceDetails
        cell.invoiceDetailsHead = invoiceDetailsHead
        cell.claim = claim
        cell.backgroundColor = UIColor.clear
        
        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            cell.populateTotalView()
        } else {
            let invoiceDetailsHeadRow = invoiceDetailsHead.rows[indexPath.row]
            cell.invoiceDetailsRow = invoiceDetailsHeadRow
            cell.populateCellView()
            
            if let claimInvoiceRow = claim.invoceRows.first(where: { $0.rowId == invoiceDetailsHeadRow.id }) {
                cell.claimInvoiceRow = claimInvoiceRow
                cell.populateClaimInvoiceView()
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow: CGFloat
        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            if claim.invoceRows.count > 0 {
                heightForRow = 44
            } else {
                heightForRow = 20
            }
        } else {
            heightForRow = 50
        }
        
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row < self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            let invoiceDetailsHeadRow = invoiceDetailsHead.rows[indexPath.row]
            performSegue(withIdentifier: K.Storyboard.SegueIdentifier.AddClaim, sender: invoiceDetailsHeadRow)
        }
    }

    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return claimsSubjects.count + 1
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel! = view as? UILabel
        if label == nil {
            label = UILabel()
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 18)
            label.textAlignment = .center
        }
        
        if row > 0 {
            label.text = claimsSubjects[row - 1].name
        } else {
            label.text = "--------"
        }
        
        //label.sizeToFit()
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        subjectPickerSelected()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return claim.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClaimDetailsPhotoCellIdentifier", for: indexPath) as! ClaimDetailsPhotoCollectionViewCell
        cell.delegate = self
        cell.photo = claim.photos[indexPath.row]
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //performSegue(withIdentifier: K.Storyboard.SegueIdentifier.ImageViewer, sender: indexPath)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true) {
            print(info)
            var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if image.size.width > 900 || image.size.height > 800 {
                image = Utils.resizeImage(image: image, targetSize: CGSize(width: 900, height: 800))
            }
            
            let imageName = UUID().uuidString + ".png"
            print(imageName)
            self.claim.photos.append(Photo(image: image, name: imageName))
            self.adjustView()
            if self.scrollView.contentSize.height > self.scrollView.frame.height {
                self.scrollView.contentOffset.y = self.scrollView.contentSize.height - self.scrollView.frame.height
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ClaimDetailsPhotoCollectionViewCellDelegate
    
    func claimDetailsPhotoCollectionViewCell(_ cell: ClaimDetailsPhotoCollectionViewCell, didClosePhoto photo: Photo) {
        let indexPath = photosCollectionView.indexPath(for: cell)!
        claim.photos.remove(at: indexPath.row)
        self.adjustView()
    }
    
    // MARK: - AddClaimViewControllerDelegate
    
    func addClaimViewController(_ addClaimViewController: AddClaimViewController, didAddClaimInvoiceRow claimInvoiceRow: Claim.InvoiceRow) {
        addClaimViewController.dismiss(animated: true) {
            self.claim.invoceRows.append(claimInvoiceRow)
            self.tableView.reloadData()
        }
    }
    
    func addClaimViewController(_ addClaimViewController: AddClaimViewController, didEditClaimInvoiceRow claimInvoiceRow: Claim.InvoiceRow) {
        addClaimViewController.dismiss(animated: true) {
            let index = self.claim.invoceRows.index(where: { $0.rowId == claimInvoiceRow.rowId })!
            self.claim.invoceRows[index] = claimInvoiceRow
            self.tableView.reloadData()
        }
    }
    
    func addClaimViewController(_ addClaimViewController: AddClaimViewController, didRemoveClaimInvoiceRow claimInvoiceRow: Claim.InvoiceRow) {
        addClaimViewController.dismiss(animated: true) {
            let index = self.claim.invoceRows.index(where: { $0.rowId == claimInvoiceRow.rowId })!
            self.claim.invoceRows.remove(at: index)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.bounds.height - 1) {
            if lastContentOffset > scrollView.contentOffset.y {
                if removeButton.transform.a < 1 && self.removeButton.layer.animationKeys() == nil {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.removeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                    })
                    UIView.animate(withDuration: 0.5, animations: {
                        self.sendButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                    })
                }
            } else if lastContentOffset < scrollView.contentOffset.y {
                if removeButton.transform.a > 0.01 && self.removeButton.layer.animationKeys() == nil{
                    UIView.animate(withDuration: 0.5, animations: {
                        self.removeButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    })
                    UIView.animate(withDuration: 0.5, animations: {
                        self.sendButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    })
                }
            }
        }
        
        lastContentOffset = scrollView.contentOffset.y
    }
}
