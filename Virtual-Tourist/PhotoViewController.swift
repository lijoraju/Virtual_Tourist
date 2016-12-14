//
//  PhotoViewController.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 14/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import UIKit
import MapKit

class PhotoViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()

            }

    // MARK: New Collection button action
    @IBAction func showNewCollection(_ sender: AnyObject) {
    }
    
}
