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
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: NotificationName.updateStudents, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUserLocation(_:)), name: NotificationName.showUserLocation, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NotificationName.updateStudents, object: nil)
        NotificationCenter.default.removeObserver(self, name: NotificationName.showUserLocation, object: nil)
    }
}

// MARK: - IBActions -

extension MapViewController {
    
    @IBAction func logoutAction(_ sender: Any) {
        showLogoutAlert { shouldLogout in
            if shouldLogout {
                BaseService.shared.logOut(success: { response in
                    self.dismiss(animated: true, completion: nil)
                }, failure: { error in
                    self.showErrorAlert(error.localizedDescription)
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
        BaseService.shared.fetchStudents(completion: { error in
            if let error = error {
                self.showErrorAlert(error.localizedDescription)
            }
        })
    }
}

// MARK: - Update UI -

extension MapViewController {
    
    @objc func update() {
        for student in appDel.students.results {
            annotations.append(createAnnotation(student.latitude, long: student.longitude, firstName: student.firstName, lastName: student.lastName, url: student.mediaURL))
        }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
        }
    }
}

// MARK: - Show User Location -

extension MapViewController {
    
    @objc func showUserLocation(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo, let studentData = userInfo["studentData"] as? StudentRequest else { return }
        let annotation = createAnnotation(studentData.latitude, long: studentData.longitude, firstName: studentData.firstName, lastName: studentData.lastName, url: studentData.mediaURL)
        annotations.append(annotation)
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.annotations)
            self.mapView.addAnnotations(self.annotations)
        }
        setupMapRect(annotation)
    }
}

// MARK: - Show Last Location On the Map -

extension MapViewController {
    
    fileprivate func setupMapRect(_ annotation: MKPointAnnotation) {
        let point = MKMapPoint(annotation.coordinate)
        let mapRect = MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1)
        mapView.setVisibleMapRect(mapRect, animated: true)
        mapView.camera.altitude *= 50
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

// MARK: - Create Annotation -

extension MapViewController {
    
    fileprivate func createAnnotation(_ lat: Double, long: Double, firstName: String, lastName: String, url: String) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        annotation.title = "\(firstName) \(lastName)"
        annotation.subtitle = url
        return annotation
    }
}
