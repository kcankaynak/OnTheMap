//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Kemal Kaynak on 29.06.20.
//  Copyright © 2020 Kemal Kaynak. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    fileprivate var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "On the Map"
        fetchStudents()
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: appDel.updateStudents, object: nil)
    }
    
    deinit {
        print("HARİTA GEBERDİ")
        NotificationCenter.default.removeObserver(self, name: appDel.updateStudents, object: nil)
    }
}

// MARK: - IBActions -

extension MapViewController {
    
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

extension MapViewController {
    
    fileprivate func fetchStudents() {
        BaseService.shared.fetchStudents(completion: { [weak self] error in
            if let error = error {
                self?.showErrorAlert(error.localizedDescription)
            }
        })
    }
}

// MARK: - Update UI -

extension MapViewController {
    
    @objc func update() {
        for student in appDel.students.results {
            annotations.append(createAnnotation(student))
        }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
        }
    }
}

// MARK: - MKMapView Delegate -

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: AppIdentifiers.Reuse.pin)
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: AppIdentifiers.Reuse.pin)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard control == view.rightCalloutAccessoryView, var subtitle = view.annotation?.subtitle! else { return }
        openSafari(&subtitle)
    }
}

// MARK: - Generate Annotation -

extension MapViewController {
    
    fileprivate func createAnnotation(_ student: StudentList) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(student.latitude), longitude: CLLocationDegrees(student.longitude))
        annotation.title = "\(student.firstName) \(student.lastName)"
        annotation.subtitle = student.mediaURL
        return annotation
    }
}
