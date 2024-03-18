//
//  CellForCollectionView.swift
//  garage
//
//  Created by Apple on 23.01.24.
//

import UIKit

class CellForCollectionView: UICollectionViewCell {

    @IBOutlet weak var tasksName: UILabel!
    @IBOutlet weak var deadline: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    static let reusableIdentifire: String = "CellForCollectionView"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
