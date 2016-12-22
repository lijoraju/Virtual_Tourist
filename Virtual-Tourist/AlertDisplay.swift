//
//  Alert.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 22/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import UIKit


// MARK: Display an alert
extension UIViewController {
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
}
