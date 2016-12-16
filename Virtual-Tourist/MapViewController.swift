//
//  ViewController.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 13/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    var editMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        longTapRecognizer()
        fetchAllSavedPins()
        mapView.delegate = self
    }

    // MARK: Drop a new pin on map view
    func addNewPin(gestureRecognizer: UIGestureRecognizer) {
        let tap = gestureRecognizer.location(in: mapView)
        let mapCoordinate = mapView.convert(tap, toCoordinateFrom: mapView)
        if gestureRecognizer.state == .began {
            let pin = Pin(context: managedContext)
            pin.latitude = mapCoordinate.latitude
            pin.longitude = mapCoordinate.longitude
            appDelegate.saveContext()
            FlickrAPI.sharedInstance.searchPhotos(searchPin: pin, context: managedContext) { (sucess,error) in
                if sucess {
                    do {
                        try self.managedContext.save()
                    }
                    catch let error as NSError {
                        print("Error occured while saving \(error) \(error.userInfo)")
                    }
                }
            }
            mapView.addAnnotation(pin)
            print("Added a new pin")
        }
    }
    
    // MARK: Recognize a long tap on map view
    func longTapRecognizer() {
        let longPress  = UILongPressGestureRecognizer(target: self, action: #selector(addNewPin(gestureRecognizer:)))
        mapView.addGestureRecognizer(longPress)
    }
    
    // MARK: Delete an existing pin on map view
    @IBAction func editButtonAction(_ sender: AnyObject) {
        if editMode {
            editMode = false
            editButton.title = "Edit"
        }
        else {
            displayAlert()
        }
    }
    
    // MARK: Fetch all the saved annotations from persistance store
    func fetchAllSavedPins() {
        var pins: [Pin] = []
        do {
            pins = try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Failed to fetch saved pins. \(error) \(error.userInfo) ")
        }
        for pin in pins {
            mapView.addAnnotation(pin)
        }
    }
    
    // MARK: Selecting a pin from map view
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let precision = 0.000001
        let latUpper = (view.annotation?.coordinate.latitude)! + precision
        let latLower = (view.annotation?.coordinate.latitude)! - precision
        let lonUpper = (view.annotation?.coordinate.longitude)! + precision
        let lonLower = (view.annotation?.coordinate.longitude)! - precision
        let predicate = NSPredicate(format: "(%K BETWEEN{\(latLower), \(latUpper)}) AND (%K BETWEEN{\(lonLower), \(lonUpper)})", #keyPath(Pin.latitude), #keyPath(Pin.longitude))
        fetchRequest.predicate = predicate
        var pin: [Pin] = []
        do {
            pin = try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("\(error) \(error.userInfo)")
        }
        if editMode {
            if pin.count > 0 {
                mapView.removeAnnotation(pin.first!)
                managedContext.delete(pin.first!)
                appDelegate.saveContext()
                print("Pin deleted")
            }
        }
        else {
            Constants.selectedPin = pin.first
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegue(withIdentifier: "MapToPhoto", sender: self)
        }
    }
    
    // MARK: Displays an alert before editing begins
    func displayAlert() {
        let alert = UIAlertController(title: "Warning!", message: "Tapping a pin will delete it permanently ", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Okay", style: .default) {
            action in
            self.editMode = true
            self.editButton.title = "Done"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

}

