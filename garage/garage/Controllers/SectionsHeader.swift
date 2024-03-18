//
//  SectionsHeader.swift
//  garage
//
//  Created by Apple on 29.01.24.
//

import UIKit

class SectionsHeader: UICollectionReusableView {
    
    static let reuserID = "SectionsHeader"
    
    let title = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customizeElements()
        setupConstrains()
    
    }
    
    private func customizeElements() {
        title.textColor = Theme.currentTheme.textColor
        title.font = UIFont(name: "Apple SD Gothic Neo", size: 15)
        title.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstrains() {
        addSubview(title)
        NSLayoutConstraint.activate([title.topAnchor.constraint(equalTo: topAnchor),
                                     title.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     title.leftAnchor.constraint(equalTo: leftAnchor),
                                     title.trailingAnchor.constraint(equalTo: trailingAnchor)
                                    ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
