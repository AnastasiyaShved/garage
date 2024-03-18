//
//  SignInModel.swift
//  garage
//
//  Created by Apple on 5.12.23.
//

import Foundation
import Firebase

struct User {
    let email: String
//    let name: String
    let uid: String
    
    init(user: Firebase.User) {
        self.uid = user.uid
        self.email = user.email ?? "нет данных"
    }
}
