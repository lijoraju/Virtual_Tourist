//
//  GCDBlackBox.swift
//  Virtual-Tourist
//
//  Created by LIJO RAJU on 13/12/16.
//  Copyright © 2016 LIJORAJU. All rights reserved.
//

import Foundation

func performUIUpdateOnMain(updates: @escaping ()-> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

