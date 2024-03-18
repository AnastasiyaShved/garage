//
//  TabBarControllerForHamePage.swift
//  garage
//
//  Created by Apple on 29.01.24.
//

import UIKit
import Localize_Swift
import Firebase
import FirebaseAuth

class TabBarControllerForHamePage: UITabBarController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "GARAGE"
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func addButton() -> UIBarButtonItem  {
        
        let logOut = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(signOutBtn))
       return logOut
    }
    
    @objc
    func signOutBtn() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        navigationController?.popToRootViewController(animated: true)
    }
}

extension TabBarControllerForHamePage: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.title = item.tag == 0 ? "GARAGE": "История обслуживания"
        self.navigationItem.rightBarButtonItem = item.tag == 0 ? nil : addButton()
    }
}
