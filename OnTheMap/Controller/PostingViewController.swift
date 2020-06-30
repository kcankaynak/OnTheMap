//
//  PostingViewController.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 30.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import UIKit
import MapKit

class PostingViewController: UIViewController {

    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Location"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == AppIdentifiers.Segue.locationResult,
            let resultVC = segue.destination as? LocationSearchResultViewController,
            let studentRequest = sender as? StudentRequest else { return }
        resultVC.studentRequest = studentRequest
    }
}

// MARK: - IBActions -

extension PostingViewController {
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findAction(_ sender: Any) {
        guard let locationText = locationField.text, !locationText.isEmpty else {
            showErrorAlert("Location field can not be empty")
            return
        }
        guard let linkText = linkField.text, !linkText.isEmpty else {
            showErrorAlert("Link field can not be empty")
            return
        }
        setIndicatorState(true)
        searchLocation(locationText, linkText: linkText)
    }
}

// MARK: - Search Location -

extension PostingViewController {
    
    fileprivate func searchLocation(_ locationText: String, linkText: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationText
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            if let error = error {
                self?.showErrorAlert("Location search is failed with error : \(error.localizedDescription)")
            } else if let searchResult = response?.mapItems.first {
                let studentRequest = StudentRequest(uniqueKey: BaseService.UserData.uniqueKey, firstName: BaseService.UserData.firstName, lastName: BaseService.UserData.lastName, mapString: locationText, mediaURL: linkText, latitude: searchResult.placemark.coordinate.latitude, longitude: searchResult.placemark.coordinate.longitude)
                self?.performSegue(withIdentifier: AppIdentifiers.Segue.locationResult, sender: studentRequest)
            } else {
                self?.showErrorAlert("Can not find your location. Please provide new one.")
            }
            self?.setIndicatorState(false)
        }
    }
}

// MARK: - Set Loading Indicator -

extension PostingViewController {
    
    fileprivate func setIndicatorState(_ visible: Bool) {
        if visible {
            loadingIndicator.startAnimating()
            locationButton.setTitle(nil, for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            locationButton.setTitle("FIND LOCATION", for: .normal)
        }
        locationField.isUserInteractionEnabled = !visible
        linkField.isUserInteractionEnabled = !visible
        locationButton.isUserInteractionEnabled = !visible
    }
}
