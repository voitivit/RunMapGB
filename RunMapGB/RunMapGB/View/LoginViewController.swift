//
//  LoginViewController.swift
//  RunMapGB
//
//  Created by emil kurbanov on 02.05.2022.
//

import UIKit
import RealmSwift
class LoginViewController: UIViewController {
    

    
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    
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
     // registrationRealm = realm.objects(UserLogin.self)
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
