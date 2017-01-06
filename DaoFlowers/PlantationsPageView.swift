//
//  PlantationsPageView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/6/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class PlantationsPageView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterContainerView: UIView!
    @IBOutlet weak var assortmentContainerView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var assortmentTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var assortmentLabel: UILabel!
    
    var spinner = RBHUD()
    weak var delegate: PlantationsPageViewDelegate?
    var assortmentTypes: [PlantationsAssortmentType] = [.ByName, .ByActivePlantations, .ByPercentsOfPurchase,]
    var assortmentPickerView: UIPickerView!
    var state: PlantationsPageViewState!
    var viewWillTransitionToSize = UIScreen.main.bounds.size
    
    var filteredPlantations: [Plantation]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Public Methods
    
    func reloadData() {
        if state.filter {
            showFilterContainerView()
        } else {
            hideFilterContainerView()
        }
        self.assortmentTextField.text = CustomLocalisedString(state.assortment.rawValue)
        self.searchTextField.text = state.searchString
        self.collectionView.contentOffset = CGPoint.zero
        self.filterPlantations()
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        assortmentLabel.text = CustomLocalisedString("Assortment")
        searchTextField.placeholder = CustomLocalisedString("TypeNameBrandToSearch")
        
        let nib = UINib(nibName:"PlantationCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "PlantationCollectionViewCellIdentifier")
        assortmentContainerView.layer.cornerRadius = 5
        searchContainerView.layer.cornerRadius = 5
        self.assortmentPickerView = self.createPickerViewForTextField(self.assortmentTextField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.filteredPlantations == nil {
            self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func assortmentTextFieldClicked(_ sender: UITextField) {
        let row = self.assortmentTypes.index(of: state.assortment)!
        self.assortmentPickerView.selectRow(row, inComponent: 0, animated: false)
    }
    
    // MARK: - Private Methods
    
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
                                         action: #selector(VarietiesPageView.doneButtonClicked(_:)))
        toolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolbar
        
        return pickerView
    }
    
    func showFilterContainerView() {
        var collectionViewFrame = collectionView.frame
        collectionViewFrame.origin.y = 80
        collectionViewFrame.size.height = 384
        collectionView.frame = collectionViewFrame
        filterContainerView.isHidden = false
    }
    
    func hideFilterContainerView() {
        var collectionViewFrame = collectionView.frame
        collectionViewFrame.origin.y = 0
        collectionViewFrame.size.height = 464
        collectionView.frame = collectionViewFrame
        filterContainerView.isHidden = true
    }
    
    func filterPlantations() {
        let term = state.searchString.lowercased()
        var filteredPlantations = state.plantations
        if filteredPlantations != nil {
            if term.characters.count > 0 {
                filteredPlantations = filteredPlantations!.filter({$0.name.lowercased().contains(term)})
            }
            filteredPlantations = Utils.sortedPlantations(filteredPlantations!, byAssortmentType: state.assortment)
        }
        
        self.filteredPlantations = filteredPlantations
    }
    
    // MARK: - Private Methods
    
    func doneButtonClicked(_ sender: UIBarButtonItem) {
        changeAssortment()
    }
    
    func changeAssortment() {
        let selectedRow = self.assortmentPickerView.selectedRow(inComponent: 0)
        let assortmentType = self.assortmentTypes[selectedRow]
        self.assortmentTextField.text = CustomLocalisedString(assortmentType.rawValue)
        self.assortmentTextField.resignFirstResponder()
        self.state.assortment = assortmentType
        if let filteredPlantations = self.filteredPlantations {
            self.filteredPlantations = Utils.sortedPlantations(filteredPlantations, byAssortmentType: assortmentType)
        }
        self.delegate?.plantationsPageView(self, didChangeState: state)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfRows = 0
        if let filteredPlantations = self.filteredPlantations {
            self.spinner.hideLoader()
            numberOfRows = filteredPlantations.count
        } else {
            self.setNeedsLayout()
        }
    
        return numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantationCollectionViewCellIdentifier", for: indexPath) as! PlantationCollectionViewCell
        cell.plantation = self.filteredPlantations![indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.plantationsPageView(self, didSelectPlantation: self.filteredPlantations![indexPath.row])
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let screenSize = self.viewWillTransitionToSize
        let columnCount: Int
        if screenSize.width < screenSize.height {
            columnCount = 1
        } else {
            columnCount = 2
        }
        
        let width = screenSize.width / CGFloat(columnCount)
        return CGSize(width: width, height: 60)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return assortmentTypes.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let titleForRow = CustomLocalisedString(assortmentTypes[row].rawValue)
        return titleForRow
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeAssortment()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == searchTextField {
            var term = NSString(string: searchTextField.text!)
            term = term.replacingCharacters(in: range, with: string) as NSString
            state.searchString = term as String
            self.filterPlantations()
            self.delegate?.plantationsPageView(self, didChangeState: state)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}

protocol PlantationsPageViewDelegate: NSObjectProtocol {
    func plantationsPageView(_ plantationsPageView: PlantationsPageView, didSelectPlantation plantation: Plantation)
    func plantationsPageView(_ plantationsPageView: PlantationsPageView, didChangeState state: PlantationsPageViewState)
}

struct PlantationsPageViewState {
    var filter: Bool
    var assortment: PlantationsAssortmentType
    var searchString: String
    var plantations: [Plantation]?
    var country: Country
    var index: Int
}
