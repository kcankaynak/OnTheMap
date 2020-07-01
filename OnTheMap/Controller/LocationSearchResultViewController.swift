//
//  LocationSearchResultViewController.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 30.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchResultViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var studentRequest: StudentRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Location"
        createAnnotation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
        }
    }
}

// MARK: - MKMapView Delegate -

extension LocationSearchResultViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: AppIdentifiers.Reuse.pin)
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: AppIdentifiers.Reuse.pin)
            pinView!.canShowCallout = true
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}

// MARK: - Generate Annotation -

extension LocationSearchResultViewController {
    
    fileprivate func createAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: studentRequest.latitude, longitude: studentRequest.longitude)
        annotation.title = studentRequest.mapString
        mapView.addAnnotations([annotation])
        setupMapRect(annotation)
    }
    
    fileprivate func setupMapRect(_ annotation: MKPointAnnotation) {
        let point = MKMapPoint(annotation.coordinate)
        let mapRect = MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1)
        mapView.setVisibleMapRect(mapRect, animated: true)
        mapView.camera.altitude *= 100
    }
}

// MARK: - Submit Action -

extension LocationSearchResultViewController {
    
    @IBAction func submitAction(_ sender: Any) {
        setIndicatorState(true)
        BaseService.shared.createUser(studentRequest, completion: { error in
            self.setIndicatorState(false)
            if let error = error {
                self.showErrorAlert(error.localizedDescription)
            } else {
                NotificationCenter.default.post(name: NotificationName.showUserLocation, object: nil, userInfo: ["studentData": self.studentRequest as Any])
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}

// MARK: - Set Loading Indicator -

extension LocationSearchResultViewController {
    
    fileprivate func setIndicatorState(_ visible: Bool) {
        if visible {
            loadingIndicator.startAnimating()
            submitButton.setTitle(nil, for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            submitButton.setTitle("SUBMIT", for: .normal)
        }
        submitButton.isUserInteractionEnabled = !visible
    }
}
