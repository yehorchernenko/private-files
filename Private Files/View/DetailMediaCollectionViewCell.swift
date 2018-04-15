//
//  DetailMediaCollectionViewCell.swift
//  Private Files
//
//  Created by Egor on 14.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import UIKit

class DetailMediaCollectionViewCell: UICollectionViewCell {
    class var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var imageView: UIImageView!
}


