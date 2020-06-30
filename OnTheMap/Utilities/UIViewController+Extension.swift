//
//  UIViewController+Extension.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 29.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showErrorAlert(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func showLogoutAlert(response: @escaping (Bool) -> ()) {
        let alertController = UIAlertController(title: "Info", message: "Are you sure to log out?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            response(true)
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            response(false)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func openSafari(_ urlString: inout String) {
        guard let url = URL(string: urlString.checkHTTPControl()), UIApplication.shared.canOpenURL(url) else {
            showErrorAlert("Safari can not open this link")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
