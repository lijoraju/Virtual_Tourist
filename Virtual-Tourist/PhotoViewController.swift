//
//  PhotoViewController.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 14/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!

    var managedContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let pin: Pin = Constants.selectedPin
    let numOfPhotos = Int(Constants.selectedPin.numOfPhotos)
    lazy var fetchedResultsController: NSFetchedResultsController<Photo> = {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "pin = %@", self.pin)
        fetchRequest.predicate = predicate
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            let error = error as NSError
            print("An error occured \(error) \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.addAnnotation(Constants.selectedPin)
        mapView.centerCoordinate = Constants.selectedPin.coordinate
        mapView.camera.altitude = 1000000
        newCollectionButton.isEnabled = pin.downloadFlag
    }

    // MARK: Load image to cell from core data data store
    func configureCell(_ cell: ImageCell, atIndexPath indexPath: IndexPath) {
        performDataUpdatesOnBackground {
            let photo = self.fetchedResultsController.object(at: indexPath)
            if let imageData = photo.image as? Data {
                performUIUpdateOnMain {
                    cell.imageCell.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCell
        cell.imageCell.image = #imageLiteral(resourceName: "placeholder-1")
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPhoto = fetchedResultsController.object(at: indexPath)
        deletePhoto(photo: selectedPhoto)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        newCollectionButton.isEnabled = pin.downloadFlag
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                collectionView.insertItems(at: [indexPath])
            }
            break
        case .delete:
            if let indexPath = indexPath {
                collectionView.deleteItems(at: [indexPath])
            }
            break
        case .update:
            if let indexPath = indexPath {
                let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
                configureCell(cell, atIndexPath: indexPath)
            }
            break
        default:
            break
        }
    }
    
    // MARK: Delete a selected photo cell from collection view and simultaneously from core data store
    func deletePhoto(photo: Photo) {
        managedContext.delete(photo)
        pin.numOfPhotos = pin.numOfPhotos - 1
        appDelegate.saveContext()
    }
    
    // MARK: New Collection button action
    @IBAction func showNewCollection(_ sender: AnyObject) {
        for object in fetchedResultsController.fetchedObjects! {
            deletePhoto(photo: object)
        }
    }
    
}
