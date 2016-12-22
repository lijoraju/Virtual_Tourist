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
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        flowLayout.minimumLineSpacing = 3.0
        flowLayout.minimumInteritemSpacing = 3.0
        do {
            try fetchedResultsController.performFetch()
        }
        catch let error as NSError {
            print("An error occured \(error) \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.addAnnotation(Constants.selectedPin)
        mapView.centerCoordinate = Constants.selectedPin.coordinate
        mapView.camera.altitude = 1000000
        setUIEnabled(enabled: pin.downloadFlag)
    }
    
    // MARK: Load image to cell from core data data store
    func configureCell(_ cell: ImageCell, atIndexPath indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        guard photo.image != nil else {
            print("No image downloaded for cell \(indexPath.row)")
            return
        }
        let imageData = photo.image
        cell.imageCell.image = UIImage(data: imageData as! Data)
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
        let downloadCompleted = pin.downloadFlag
        if !downloadCompleted {
            cell.imageCell.image = #imageLiteral(resourceName: "placeholder")
            return cell
        }
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPhoto = fetchedResultsController.object(at: indexPath)
        performUIUpdateOnMain() {
            self.deletePhoto(photo: selectedPhoto)
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                performUIUpdateOnMain() {
                    self.collectionView.insertItems(at: [indexPath])
                }
            }
            break
        case .delete:
            if let indexPath = indexPath {
                performUIUpdateOnMain() {
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
            break
        case .update:
            let downloadCompleted = pin.downloadFlag
            if downloadCompleted {
                performUIUpdateOnMain {
                    self.collectionView.reloadData()
                    self.setUIEnabled(enabled: true)
                }
            }
            break
        default:
            break
        }
    }
    
    // MARK: Delete a selected photo cell from collection view and simultaneously from core data store
    func deletePhoto(photo: Photo) {
        managedContext.delete(photo)
        appDelegate.saveContext()
    }
    
    // MARK: New Collection button action
    @IBAction func showNewCollection(_ sender: AnyObject) {
        setUIEnabled(enabled: false)
        for object in fetchedResultsController.fetchedObjects! {
            performUIUpdateOnMain {
                self.deletePhoto(photo: object)
            }
        }
        pin.downloadFlag = false
        appDelegate.saveContext()
        FlickrAPI.sharedInstance.searchPhotos(searchPin: pin, context: managedContext) { (sucess, error) in
            if sucess {
                FlickrAPI.sharedInstance.downloadImages(addedPin: self.pin, context: self.managedContext) { (sucess, error) in
                    if sucess {
                        print("New collection downloaded")
                    }
                }
            }
        }
    }
    
    // MARK: Configure UI
    func setUIEnabled(enabled: Bool) {
        newCollectionButton.isEnabled = enabled
    }
    
}

// MARK: UICollectionViewDelegateFlowlayout
extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: Telling the layout the size for a given cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
}
