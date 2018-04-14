//
//  MediaCollectionViewCell.swift
//  Private Files
//
//  Created by Egor on 14.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell {
 
    class var identifier: String {
        return String(describing: self)
    }
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    func configureCell(withMedia media: MediaItem){
        self.previewImageView.image = media.previewImage
        
        self.playImageView.isHidden = media.assetType == AssetType.video.rawValue ? false : true
    }
}
