//
//  RegistrationVC.swift
//  garage
//
//  Created by Apple on 21.11.23.
//

import UIKit
import Firebase
import FirebaseAuth

class RegistrationVC: UIViewController {
    // MARK: - Properties
    var ref: DatabaseReference!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var confirmPasswordLbl: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirnPasswordTF: UITextField!
    @IBOutlet weak var registration: UIButton!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        ref = Database.database().reference(withPath: "users")
    }
    
    

    // MARK: - Actions
    @IBAction func registrationBtb(_ sender: UIButton) {
        guard let name = nameTF.text,
              let email = emailTF.text,
              let password = passwordTF.text,
              let confirnPassword = confirnPasswordTF.text,
              !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirnPassword.isEmpty
        else  {
            //добавить проверkу на совпадение пароля и чтобы TF подввечивался красным при отсутствии жанных
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [ weak self ] user, error in
            if let error = error {
                print(error)
                //обработать в зависимости от конкретного поля
                self?.errorNotification(object: self?.emailTF)
                self?.errorNotification(object: self?.passwordTF)
            } else if let user = user {
                let userRef = self?.ref.child(user.user.uid)
                userRef?.setValue(["email": user.user.email])
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    // MARK: - Private functions
    
    private func applyTheme() {
        self.view.backgroundColor = Theme.currentTheme.backgroundColor
        nameLbl.textColor = Theme.currentTheme.textColor
        emailLbl.textColor = Theme.currentTheme.textColor
        passwordLbl.textColor = Theme.currentTheme.textColor
        confirmPasswordLbl.textColor = Theme.currentTheme.textColor
        registration.tintColor = Theme.currentTheme.buttonColor
    }
    
    private func errorNotification (object: UITextField!) {
        guard let object = object else { return }
         object.backgroundColor = .red.withAlphaComponent(0.05)
    }
    //убирать заливку посмле очищения TF
    
    
    deinit {
        print("deinited registrationVC")
    }
}
