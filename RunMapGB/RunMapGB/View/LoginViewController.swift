//
//  LoginViewController.swift
//  RunMapGB
//
//  Created by emil kurbanov on 02.05.2022.
//

import UIKit
import Foundation
import RealmSwift
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {

    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var logInOutlet: UIButton!
    @IBOutlet weak var registrationOutlet: UIButton!
    var registrationRealm: Results<Users>!
    var user = Users()
    var router: LaunchRouter?
    let realm = try! Realm()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        router = LaunchRouter(viewController: self)
        registrationRealm = realm.objects(Users.self)
       // realm.configuration.deleteRealmIfMigrationNeeded == true
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
       // blurColor()
        settingsTextFields()
        addObserver()
        configureLoginBindings()
     // registrationRealm = realm.objects(UserLogin.self)
    }

    func configureLoginBindings() {
        Observable
            .combineLatest(
                loginView.rx.text,
                passwordView.rx.text
            )
            .map { login, password in
                guard let login = self.loginView.text, let password = self.passwordView.text else  { return false }
                return !login.isEmpty && password.count >= 1
            }
            .bind { [weak logInOutlet] inputFilled  in
                logInOutlet?.isEnabled = inputFilled
                
            }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(blurViewLoading), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(normalViewLoading), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
   @objc private func blurViewLoading() {
       let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 1
       self.view.addSubview(blurEffectView)
       
    }
    @objc private func normalViewLoading() {
        self.view.viewWithTag(1)?.removeFromSuperview()
    }

    func settingsTextFields() {
        loginView.autocorrectionType = .no
        loginView.autocapitalizationType = .none
        loginView.backgroundColor = .green
        passwordView.autocorrectionType = .no
        passwordView.autocapitalizationType = .none
        passwordView.backgroundColor = .green
        passwordView.isSecureTextEntry = true
        
            }
    private func logInButtonTapped() {
        guard
            let login = loginView.text,
            let password = passwordView.text else { return }
        
        if login.isEmpty || password.isEmpty {
            let alert = UIAlertController(title: "Требуется ввести логин и пароль!", message: "Вы не заполнили поля", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        } else {
            user.login = login
            user.password = password
            if (realm.object(ofType: Users.self, forPrimaryKey: "\(login)") != nil) {
                router?.toMapViewController()
                //  performSegue(withIdentifier: "show", sender: self)
            } else {
                let alert = UIAlertController(title: "Неверные логин и пароль", message: "Повторите попытку", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
                
        
    }
    
    private func registerButtonTapped() {
        guard
            let login = loginView.text,
            let password = passwordView.text
        else { return }
        
        if login.isEmpty || password.isEmpty {
            let alert = UIAlertController(title: "Заполните все поля", message: "Заполните и продолжайте", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            user.login = login
            user.password = password
            
            if realm.object(ofType: Users.self, forPrimaryKey: "\(login)") != nil {
                let alert = UIAlertController(title: "Такой пользователь уже зарегистрирован", message: "Пожалуйста, введите новые данные!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else {
                try! realm.write {
                    realm.add(user)
                }
                router?.toMapViewController()
                // performSegue(withIdentifier: "show", sender: self)
            }
            
            
            }
    }
    
    
    @IBAction func logIn(_ sender: Any) {
        logInButtonTapped()
    }
    
    @IBAction func register(_ sender: Any) {
       registerButtonTapped()

}
}
