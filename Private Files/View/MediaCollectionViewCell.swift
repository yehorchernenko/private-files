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
    
    var media: MediaItem?
    
    
    func configureCell(withMedia media: MediaItem, motionId: String){
        /*media.getPreviewImage { [weak self] image in
            self?.previewImageView.image = image
        }*/
        self.media = media
        playImageView.isHidden = media.assetType != AssetType.video.rawValue
        motionIdentifier = motionId
        transition(.fadeOut, .scale(0.75))
    }
    
    func playVideoIfPossible(withMedia media: MediaItem){
    }
}
