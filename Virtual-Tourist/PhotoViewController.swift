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
    @IBOutlet weak var noImagesLabel: UILabel!

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
            FlickrAPI.sharedInstance.downloadImages(imagePath: photo.url!) { imageData, error in
                if error == nil {
                    cell.imageCell.image = UIImage(data: imageData!)
                    performUIUpdateOnMain {
                        if photo.index == self.pin.numOfPhotos {
                            self.pin.downloadFlag = true
                        }
                        photo.image = imageData as NSData?
                        save(context: self.managedContext) { sucess in
                            if sucess {
                                print("Downloaded and saved photo for index \(photo.index)")
                            }
                        }
                    }
                }
                else {
                    print(error)
                }
            }
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
            configureCell(cell, atIndexPath: indexPath)
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
                collectionView.insertItems(at: [indexPath])
            }
            break
        case .delete:
            if let indexPath = indexPath {
                collectionView.deleteItems(at: [indexPath])
            }
            break
        case .update:
            let downloadCompleted = pin.downloadFlag
            if downloadCompleted {
                setUIEnabled(enabled: true)
                collectionView.reloadData()
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
        print("saved")
        sentRequestToFlickrAPI(requestForPin: pin, managedObjectContext: managedContext) { (sucess, errorTitle, errorMessage) in
            if sucess {
                print("New Collection Determined")
            }
            else {
                performUIUpdateOnMain {
                    self.displayAlert(title: errorTitle!, message: errorMessage!)
                    self.setUIEnabled(enabled: true)
                }
            }
        }
    }
    
    // MARK: Back button action
    @IBAction func backToMap(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Configure UI
    func setUIEnabled(enabled: Bool) {
        let numOfPhotos = Int(pin.numOfPhotos)
        if numOfPhotos == 0 {
            noImagesLabel.isHidden = false
            collectionView.isHidden = true
            newCollectionButton.isEnabled = true
        }
        else {
            noImagesLabel.isHidden = true
            collectionView.isHidden = false
            newCollectionButton.isEnabled = enabled
        }
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
