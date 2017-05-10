//
//  AddClaimViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 4/22/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class AddClaimViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet var cornerRadiusViews: [UIView]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stemsTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var varietyLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var stemsCountLabel: UILabel!
    @IBOutlet weak var stemPriceLabel: UILabel!
    @IBOutlet weak var fullPriceLabel: UILabel!
    @IBOutlet weak var discountTextField: UITextField!
    @IBOutlet weak var percentDiscountTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate: AddClaimViewControllerDelegate?
    var invoiceDetails: InvoiceDetails!
    var invoiceDetailsHead: InvoiceDetails.Head!
    var invoiceDetailsRow: InvoiceDetails.Row!
    var claimTypes: [ClaimType] = [.Discount, .PercentDiscount, .FullPrice, .WithoutDiscount]
    var selectedClaimType: ClaimType = .FullPrice
    var claimInvoiceRow: Claim.InvoiceRow!
    var claimTotalPrice: Double?
    var claimPercentDiscount: Int?
    var claimDiscount: Double?
    var editingMode: Bool = false
    let redColor = UIColor(red: 255/255, green: 72/255, blue: 72/255, alpha: 1.0)
    let yellowColor = UIColor(red: 255/255, green: 253/255, blue: 85/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(width: 320, height: 693)
        
        cornerRadiusViews.forEach { (view) in
            view.layer.cornerRadius = 5
            view.layer.borderColor = UIColor(red: 100/250.0, green: 100/250.0, blue: 100/250.0, alpha: 1.0).cgColor
            view.layer.borderWidth = 1
        }
     
        containerView.layer.cornerRadius = 3
        
        if claimInvoiceRow == nil {
            claimInvoiceRow = Claim.InvoiceRow(rowId: invoiceDetailsRow.id)
        } else {
            editingMode = true
            validateClaim()
        }
        
        populateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Private Method
    
    func populateView() {
        let flower = invoiceDetails.flowerById(invoiceDetailsHead.flowerTypeId)!
        flowerLabel.text = flower.name
        let variety = invoiceDetails.varietyById(invoiceDetailsRow.flowerSortId)!
        varietyLabel.text = variety.name
        let flowerSize = invoiceDetails.flowerSizeById(invoiceDetailsRow.flowerSizeId)!
        sizeLabel.text = flowerSize.name
        
        stemsCountLabel.text = String(invoiceDetailsRow.stems)
        stemPriceLabel.text =  String(format: "%.3f", invoiceDetailsRow.stemPrice)
        fullPriceLabel.text = String(invoiceDetailsRow.cost)
        
        discountTextField.placeholder = "< " + stemPriceLabel.text!
        
        if let claimStems = claimInvoiceRow.claimStems {
            stemsTextField.text = String(claimStems)
            if let claimPerStemPrice = claimInvoiceRow.claimPerStemPrice {
                priceTextField.text = String(format: "%.2f", Double(claimStems) * claimPerStemPrice)
            }
        }
        
        var toolbar = UIToolbar()
        toolbar.sizeToFit()
        var doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: stemsTextField,
                                         action: #selector(resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        stemsTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                         style: UIBarButtonItemStyle.done,
                                         target: discountTextField,
                                         action: #selector(resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        discountTextField.inputAccessoryView = toolbar
        
        toolbar = UIToolbar()
        toolbar.sizeToFit()
        doneButton = UIBarButtonItem(title: CustomLocalisedString("Done"),
                                     style: UIBarButtonItemStyle.done,
                                     target: percentDiscountTextField,
                                     action: #selector(resignFirstResponder))
        toolbar.setItems([doneButton], animated: true)
        percentDiscountTextField.inputAccessoryView = toolbar
    }
    
    func keyboardWillShow(_ notification:Notification){
        scrollView.isScrollEnabled = true
        scrollView.contentOffset = CGPoint(x: 0, y: 125)
    }
    
    func keyboardWillHide(_ notification:Notification){
        scrollView.isScrollEnabled = false
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func resetDiscountTextField() {
        discountTextField.backgroundColor = UIColor.white
        discountTextField.isEnabled = false
        discountTextField.text = ""
        claimDiscount = nil
    }
    
    func resetPercentDiscountTextField() {
        percentDiscountTextField.backgroundColor = UIColor.white
        percentDiscountTextField.isEnabled = false
        percentDiscountTextField.text = ""
        claimPercentDiscount = nil
    }
    
    func validateClaim() -> Bool {
        var result = false
        
        claimTotalPrice = nil
        stemsTextField.backgroundColor = UIColor.white
        percentDiscountTextField.backgroundColor = UIColor.white
        discountTextField.backgroundColor = UIColor.white

        if let claimStems = claimInvoiceRow.claimStems {
            if claimStems > 0 && invoiceDetailsRow.stems >= claimStems {
                stemsTextField.backgroundColor = yellowColor
                
                switch selectedClaimType {
                case .Discount:
                    if let claimDiscount = claimDiscount {
                        claimTotalPrice = Double(claimStems) * claimDiscount
                        if 0 < claimDiscount && claimDiscount < invoiceDetailsRow.stemPrice {
                            discountTextField.backgroundColor = yellowColor
                            result = true
                        } else {
                            discountTextField.backgroundColor = redColor
                        }
                    }
                    discountTextField.isEnabled = true
                    resetPercentDiscountTextField()
                case .PercentDiscount:
                    if let claimPercentDiscount = claimPercentDiscount {
                        claimTotalPrice = Double(claimStems) * invoiceDetailsRow.stemPrice * (Double(claimPercentDiscount) / 100.0)
                        if 0 < claimPercentDiscount && claimPercentDiscount < 100 {
                            percentDiscountTextField.backgroundColor = yellowColor
                            result = true
                        } else {
                            percentDiscountTextField.backgroundColor = redColor
                        }
                    }
                    percentDiscountTextField.isEnabled = true
                    resetDiscountTextField()
                case .FullPrice:
                    claimTotalPrice = Double(claimStems) * invoiceDetailsRow.stemPrice
                    resetDiscountTextField()
                    resetPercentDiscountTextField()
                    result = true
                case .WithoutDiscount:
                    claimTotalPrice = 0
                    resetDiscountTextField()
                    resetPercentDiscountTextField()
                    result = true
                }
            } else {
                stemsTextField.backgroundColor = redColor
            }
        }
        
        if let claimTotalPrice = claimTotalPrice {
            priceTextField.text = String(format: "%.2f", claimTotalPrice)
            priceTextField.backgroundColor = UIColor(red: 255/255, green: 253/255, blue: 85/255, alpha: 1.0)
        } else {
            priceTextField.text = "?"
            priceTextField.backgroundColor = UIColor(red: 255/255, green: 72/255, blue: 72/255, alpha: 1.0)
        }
        
        return result
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return claimTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddClaimTypeTableViewCellIdentifier", for: indexPath)
        let claimType = claimTypes[indexPath.row]
        cell.textLabel?.text = claimType.rawValue
        
        if claimType == selectedClaimType {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath)!
        if cell.accessoryType != UITableViewCellAccessoryType.checkmark {
            selectedClaimType = claimTypes[indexPath.row]
            tableView.reloadData()
            validateClaim()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func clearButtonClicked(_ sender: UIButton) {
        if editingMode {
            delegate?.addClaimViewController(self, didRemoveClaimInvoiceRow: claimInvoiceRow)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        if validateClaim() {
            claimInvoiceRow.claimPerStemPrice = claimTotalPrice!/Double(claimInvoiceRow.claimStems!)
            if editingMode {
                delegate?.addClaimViewController(self, didEditClaimInvoiceRow: claimInvoiceRow)
            } else {
                delegate?.addClaimViewController(self, didAddClaimInvoiceRow: claimInvoiceRow)
            }
        } else {
            Utils.showErrorWithMessage("Validation mistake! Please, check whether you filled in the lines correctly.", inViewController: self)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let string = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        var value: Double = 0
        if let v = Double(string) {
            value = v
        }
        
        switch textField {
        case stemsTextField:
            if string.characters.count > 0 {
                claimInvoiceRow.claimStems = Int(value)
            } else {
                claimInvoiceRow.claimStems = nil
            }
        case percentDiscountTextField:
            if string.characters.count > 0 {
                claimPercentDiscount = Int(value)
            } else {
                claimPercentDiscount = nil
            }
        case discountTextField:
            if string.characters.count > 0 {
                claimDiscount = value
            } else {
                claimDiscount = nil
            }
        default:
            break
        }
        
        validateClaim()
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    enum ClaimType: String {
        case Discount = "Discount"
        case PercentDiscount = "% discount"
        case FullPrice = "Full Price"
        case WithoutDiscount = "Without discount"
    }
}

protocol AddClaimViewControllerDelegate: NSObjectProtocol {
    func addClaimViewController(_ addClaimViewController: AddClaimViewController, didAddClaimInvoiceRow claimInvoiceRow: Claim.InvoiceRow)
    
    func addClaimViewController(_ addClaimViewController: AddClaimViewController, didEditClaimInvoiceRow claimInvoiceRow: Claim.InvoiceRow)
    
    func addClaimViewController(_ addClaimViewController: AddClaimViewController, didRemoveClaimInvoiceRow claimInvoiceRow: Claim.InvoiceRow)
}
