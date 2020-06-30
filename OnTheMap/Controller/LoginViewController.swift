//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 29.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import UIKit

let appDel = UIApplication.shared.delegate as! AppDelegate

class LoginViewController: UIViewController {

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - IBActions -

extension LoginViewController {
    
    @IBAction func loginAction(_ sender: Any) {
        mailTextField.text = "kcankaynak@gmail.com"
        passwordField.text = "AmE05TuR"
        guard let mailText = mailTextField.text, !mailText.isEmpty else {
            showErrorAlert("Mail field can not be empty")
            return
        }
        guard let passwordText = passwordField.text, !passwordText.isEmpty else {
            showErrorAlert("Password can not be empty")
            return
        }
        setLoginIndicatorState(true)
        BaseService.shared.logInService(mailText, password: passwordText, success: { (response) in
            self.setLoginIndicatorState(false)
            self.performSegue(withIdentifier: "showMap", sender: self)
            self.clearTextFields()
        }, failure: { [weak self] error in
            self?.showErrorAlert(error.localizedDescription)
            self?.setLoginIndicatorState(false)
        })
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        UIApplication.shared.open(BaseService.EndPoints.webAuth.url, options: [:], completionHandler: nil)
    }
}

// MARK: - Helper Methods -

extension LoginViewController {
    
    private func setLoginIndicatorState(_ visible: Bool) {
        if visible {
            loginIndicator.startAnimating()
            loginButton.setTitle(nil, for: .normal)
        } else {
            loginIndicator.stopAnimating()
            loginButton.setTitle("LOG IN", for: .normal)
        }
        mailTextField.isUserInteractionEnabled = !visible
        passwordField.isUserInteractionEnabled = !visible
        loginButton.isUserInteractionEnabled = !visible
    }
    
    private func clearTextFields() {
        mailTextField.text = nil
        passwordField.text = nil
    }
}
