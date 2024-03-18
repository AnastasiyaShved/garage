//
//  signInVC.swift
//  garage
//
//  Created by Apple on 20.11.23.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftUI

enum TextFieldState {
    case normal
    case incorrectEmail
    case incorrectPassword
    case unrecognizedError(String)
}

protocol SignInVCProtocol: AnyObject {
    func goToHomePage()
    func updateUI(type: TextFieldState)
}

class SignInVC: UIViewController {
    
    @AppStorage(wrappedValue: 1, "currentPage") var currentPage
    
    // MARK: - Properties
    /// для связи с SignInPresenter создаем переменную
    var presenter: SignInPresenterProtocol!
    
    //создаем переменную для абзервера
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!

    private let eyeButton = EyeButton()
    private var isPrivate = true
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var noAccountLbL: UILabel!
    @IBOutlet weak var forgetPassword: UIButton!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet  var passwordTF: UITextField!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authService = AuthServiceImpl()
        presenter = SignInPresenter(authService: authService)
        presenter.controller = self
        
        applyTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
        
        emailTF.delegate = self
        passwordTF.delegate = self
        
        setupPasswordTF()
        addActions()
        
        stateDidChangeListenerHandle()
        
        startOnbording()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTF.text = "pav159208@gmail.com" // will change nil
        passwordTF.text = "1722104Pion" 
        emailTF.backgroundColor = nil
        passwordTF.backgroundColor = nil
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @IBAction func forgetPasswordBtn(_ sender: UIButton) {
    }
    
    @IBAction func registerBtn(_ sender: UIButton) {
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        presenter.tapSignInBtn(email: emailTF.text, password: passwordTF.text)
    }
 
    // MARK: - Private functions
    private func applyTheme() {
        self.view.backgroundColor = Theme.currentTheme.backgroundColor
        emailLbl.textColor = Theme.currentTheme.textColor
        passwordLbl.textColor = Theme.currentTheme.textColor
        noAccountLbL.textColor = Theme.currentTheme.textColor
        register.tintColor = Theme.currentTheme.textColorForReference
        forgetPassword.tintColor = Theme.currentTheme.textColorForReference
        button.tintColor = Theme.currentTheme.buttonColor
    }
    
    //    функция для отслежтиывания схода в учетку
    private func stateDidChangeListenerHandle() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener({ [ weak self ] _, user in
            guard let user = user else { return }
            //self?.goToHome() 
        })
    }
    
    private func errorNotification(object: UITextField!) {
        guard let object = object else { return }
         object.backgroundColor = .red.withAlphaComponent(0.05)
    }
    
    @objc
    private func kbWillShow(notification: Notification) {
        view.frame.origin.y = 0
        if let keyboardsize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.origin.y -= keyboardsize.height / 2
        }
    }
    
    @objc
    private func kbWillHide(notification: Notification) {
        view.frame.origin.y = 0
    }
    ///метод для  отображения картинки на кнопке
    @objc
    private func displayBookMarks() {
        let imageName = isPrivate ? "eye" : "eye.slash"
        
        passwordTF.isSecureTextEntry.toggle()
        eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
        isPrivate.toggle()
        
    }
}

// MARK: - Extension
extension SignInVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.restorationIdentifier == "email" {
            print("email first responder")
            checgebackroundColorForTF(object: emailTF)
        } else {
            print("password first responder")
            checgebackroundColorForTF(object: passwordTF)
        }
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text  = textField.text else { return }
        eyeButton.isEnabled = !text.isEmpty
    }
    
}
private extension SignInVC {
    ///метод добавления кнопки на TF
    func setupPasswordTF() {
        ///отслеживаем пустое поле или нет
        passwordTF.delegate = self
        
        ///добавляем элемент с нужной стороны
        passwordTF.rightView = eyeButton
        ///устанавливаем, когда  отображать
        passwordTF.rightViewMode = .always
    }
    /// метод для реализации action
    func addActions() {
        eyeButton.addTarget(self, action: #selector(displayBookMarks), for: .touchUpInside)
    }
    
    func checgebackroundColorForTF(object: UITextField!) {
        guard let object = object else { return }
         object.backgroundColor = .white
    }
    
    func goToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(identifier:  "NewHomePage") as? TabBarControllerForHamePage {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func startOnbording() {
        if currentPage <= 3 {
            currentPage = 1
            let vc = OnbordingHost()
            vc.modalPresentationStyle = .fullScreen
            
            self.navigationController?.present(vc, animated: false)
        }
    }
}

extension SignInVC: SignInVCProtocol {
    
    func goToHomePage() {
        goToHome()
    }
    
    func updateUI(type: TextFieldState) {
        switch type {
        case .normal:
            break
        case .incorrectEmail:
            errorNotification(object: emailTF)
        case .incorrectPassword:
            errorNotification(object: passwordTF)
        case .unrecognizedError(let message):
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alertController.addAction(cancelAction)
            self.navigationController?.present(alertController, animated: true)
        }
    }
}
