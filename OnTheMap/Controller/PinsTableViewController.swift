//
//  PinsTableViewController.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 29.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import UIKit

class PinsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "On the Map"
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: appDel.updateStudents, object: nil)
    }
    
    deinit {
        print("TABLO GEBERDİ")
        NotificationCenter.default.removeObserver(self, name: appDel.updateStudents, object: nil)
    }
}

// MARK: - IBActions -

extension PinsTableViewController {
    
    @IBAction func logoutAction(_ sender: Any) {
        showLogoutAlert { [weak self] shouldLogout in
            if shouldLogout {
                BaseService.shared.logOutService(success: { response in
                    self?.dismiss(animated: true, completion: nil)
                }, failure: { error in
                    self?.showErrorAlert(error.localizedDescription)
                })
            }
        }
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        fetchStudents()
    }
}

// MARK: - Fetch Students -

extension PinsTableViewController {
    
    fileprivate func fetchStudents() {
        BaseService.shared.fetchStudents(completion: { [weak self] error in
            if let error = error {
                self?.showErrorAlert(error.localizedDescription)
            }
        })
    }
}

// MARK: - UITableView Data Source -

extension PinsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDel.students.results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppIdentifiers.Reuse.pinTableCell, for: indexPath) as? PinsTableViewCell else {
            return UITableViewCell()
        }
        cell.nameLabel.text = appDel.students.results[indexPath.row].firstName + " " + appDel.students.results[indexPath.row].lastName
        cell.linkLabel.text = appDel.students.results[indexPath.row].mediaURL
        return cell
    }
}

// MARK: - UITableView Delegate -

extension PinsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var linkString = appDel.students.results[indexPath.row].mediaURL
        openSafari(&linkString)
    }
}

// MARK: - Update UI -

extension PinsTableViewController {
    
    @objc func update() {
        tableView.reloadData()
    }
}
