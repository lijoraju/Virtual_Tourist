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

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        longTapRecognizer()
        fetchAllSavedPins()
        
    }

    // MARK: Drop a new pin on map view
    func addNewPin(gestureRecognizer: UIGestureRecognizer) {
        let tap = gestureRecognizer.location(in: mapView)
        let mapCoordinate = mapView.convert(tap, toCoordinateFrom: mapView)
        if gestureRecognizer.state == .began {
            let pin = Pin(context: managedContext)
            pin.latitude = mapCoordinate.latitude
            pin.longitude = mapCoordinate.longitude
            mapView.addAnnotation(pin)
            appDelegate?.saveContext()
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

}

