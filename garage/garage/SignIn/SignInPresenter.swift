//
//  SignInPresenter.swift
//  garage
//
//  Created by Apple on 5.12.23.
//

import UIKit
import FirebaseAuth
//создаем обстрактный протокол
protocol SignInPresenterProtocol: AnyObject {
    var controller: SignInVCProtocol? { get set }
    func tapSignInBtn(email: String?, password: String?)
}

class SignInPresenter {
    
    weak var controller: SignInVCProtocol? = nil
    var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
}

extension SignInPresenter: SignInPresenterProtocol {
    
    func tapSignInBtn(email: String?, password: String?) {
        guard let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else {
            return
        }
        
        authService.signIn(with: email, password: password) { [weak self] result in
            switch result {
            case .success(let user):
                self?.controller?.goToHomePage()
            case .failure(let error):
                guard let error = error as? NSError else {
                    print("error is not NSError")
                    return
                }
                switch AuthErrorCode.Code(rawValue: error.code) {
                case .invalidEmail, .missingEmail:
                    self?.controller?.updateUI(type: .incorrectEmail)
                case .wrongPassword:
                    self?.controller?.updateUI(type: .incorrectPassword)
                default:
                    self?.controller?.updateUI(type: .unrecognizedError(error.localizedDescription))
                }
            }
        }
    }
}
