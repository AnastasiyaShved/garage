//
//  CellForAoto.swift
//  garage
//
//  Created by Apple on 24.01.24.
//

import UIKit

protocol CellAutoDelegate: AnyObject {
    func openAutoDetail()
}

class CellForAuto: UICollectionViewCell {
    
    weak var delegate: CellAutoDelegate?

    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? Theme.currentTheme.buttonColor : Theme.currentTheme.backgroundColor
            self.button.backgroundColor =  !isSelected ? Theme.currentTheme.buttonColor : Theme.currentTheme.backgroundColor
            self.button.tintColor = isSelected ? Theme.currentTheme.buttonColor : Theme.currentTheme.backgroundColor
            self.autosName.textColor = isSelected ? .white : Theme.currentTheme.textColor
            self.mileage.textColor = isSelected ? .white : Theme.currentTheme.textColor
        }
    }
    
    @IBOutlet weak var autosName: UILabel!
    @IBOutlet weak var autosModel: UILabel!
    @IBOutlet weak var mileage: UILabel!
    @IBOutlet weak var button: UIButton!
    
    static let reusableIdentifire: String = "CellForAoto"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settingButton()
    }
    @IBAction func openDetails(_ sender: Any) {
        if isSelected {
            delegate?.openAutoDetail()
        }
    }
    
    private func settingButton() {
        button.layer.cornerRadius = button.frame.width/2
        button.layer.masksToBounds = false
    }
}
