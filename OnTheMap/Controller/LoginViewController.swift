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
}

// MARK: - IBActions -

extension LoginViewController {
    
    @IBAction func loginAction(_ sender: Any) {
        guard let mailText = mailTextField.text, !mailText.isEmpty else {
            showErrorAlert("Mail field can not be empty")
            return
        }
        guard let passwordText = passwordField.text, !passwordText.isEmpty else {
            showErrorAlert("Password can not be empty")
            return
        }
        setLoginIndicatorState(true)
        BaseService.shared.logIn(mailText, password: passwordText, success: { (response) in
            self.setLoginIndicatorState(false)
            self.performSegue(withIdentifier: "showMap", sender: self)
            self.clearTextFields()
        }, failure: { error in
            self.showErrorAlert(error.localizedDescription)
            self.setLoginIndicatorState(false)
        })
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        UIApplication.shared.open(BaseService.EndPoints.webAuth.url, options: [:], completionHandler: nil)
    }
}

// MARK: - Helper Methods -

extension LoginViewController {
    
    private func setLoginIndicatorState(_ visible: Bool) {
        visible ? loginIndicator.startAnimating() : loginIndicator.stopAnimating()
        visible ? loginButton.setTitle(nil, for: .normal) : loginButton.setTitle("LOG IN", for: .normal)
        mailTextField.isUserInteractionEnabled = !visible
        passwordField.isUserInteractionEnabled = !visible
        loginButton.isUserInteractionEnabled = !visible
    }
    
    private func clearTextFields() {
        mailTextField.text = nil
        passwordField.text = nil
    }
}
