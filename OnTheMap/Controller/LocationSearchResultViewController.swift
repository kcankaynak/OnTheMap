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
    var studentRequest: StudentRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Location"
        createAnnotation()
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
        guard let studentRequest = studentRequest else {
            showErrorAlert("Can not show location")
            return
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: studentRequest.latitude, longitude: studentRequest.longitude)
        annotation.title = studentRequest.mapString
        DispatchQueue.main.async {
            self.mapView.addAnnotations([annotation])
        }
        let point = MKMapPoint(annotation.coordinate)
        let mapRect = MKMapRect(x: point.x, y: point.y, width: 0.001, height: 0.001)
        mapView.setVisibleMapRect(mapRect, animated: true)
    }
}
