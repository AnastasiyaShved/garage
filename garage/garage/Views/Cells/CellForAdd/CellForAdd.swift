//
//  CellForAdd.swift
//  garage
//
//  Created by Apple on 24.01.24.
//

import UIKit

class CellForAdd: UICollectionViewCell {
   
    @IBOutlet weak var button: UIButton!
    
    static let reusableIdentifire: String = "CellForAdd"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func addBtn(_ sender: UIButton) {

    }

}
