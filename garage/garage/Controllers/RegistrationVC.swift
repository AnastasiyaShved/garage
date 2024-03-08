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
    
    private let eyeButtonPassword = EyeButton()
    private let eyeButtonconfirnPassword = EyeButton()
    
    private var isPrivatePass = true
    private var isPrivateConfirnPass = true
    
    
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
        
        setupPasswordTF(textField: passwordTF, button: eyeButtonPassword)
        setupPasswordTF(textField: confirnPasswordTF, button: eyeButtonconfirnPassword)
        addActions()
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
            if let error = error as? NSError {
                print(error)
                switch AuthErrorCode.Code(rawValue: error.code) {
                
                case .invalidEmail:
                    print("invalid email")
                    self?.errorNotification(object: self?.emailTF)
                case .weakPassword:
                    print("weak password")
                    self?.errorNotification(object: self?.passwordTF)
                case .missingEmail:
                    self?.errorNotification(object: self?.emailTF)
                default:
                    print(error.description)
                }
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

    ///метод для  отображения картинки на кнопке
    
    @objc
    private func displayBookMarks1() {
        let imageName = isPrivatePass ? "eye" : "eye.slash"
        
        passwordTF.isSecureTextEntry.toggle()
        eyeButtonPassword.setImage(UIImage(systemName: imageName), for: .normal)
        isPrivatePass.toggle()
    }
    
    @objc
    private func displayBookMarks2() {
        let imageName = isPrivateConfirnPass ? "eye" : "eye.slash"
        
        confirnPasswordTF.isSecureTextEntry.toggle()
        eyeButtonconfirnPassword.setImage(UIImage(systemName: imageName), for: .normal)
        isPrivateConfirnPass.toggle()
    }
    deinit {
        print("deinited registrationVC")
    }
}

extension RegistrationVC: UITextFieldDelegate {
   
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text  = passwordTF.text else { return }
        eyeButtonPassword.isEnabled = !text.isEmpty
        
        guard let text  = confirnPasswordTF.text else { return }
        eyeButtonconfirnPassword.isEnabled = !text.isEmpty
        
    }
}

private extension RegistrationVC {
    ///метод добавления кнопки на TF
    func setupPasswordTF(textField: UITextField, button: UIButton) {
        ///отслеживаем пустое поле или нет
        textField.delegate = self
        
        ///добавляем элемент с нужной стороны
        textField.rightView = button
        ///устанавливаем, когда  отображать
        textField.rightViewMode = .always
    }
    /// метод для реализации action
    func addActions() {
        eyeButtonPassword.addTarget(self, action: #selector(displayBookMarks1), for: .touchUpInside)
        eyeButtonconfirnPassword.addTarget(self, action: #selector(displayBookMarks2), for: .touchUpInside)
    }
}
