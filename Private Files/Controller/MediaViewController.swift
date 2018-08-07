//
//  MediaViewController.swift
//  Private Files
//
//  Created by Egor on 14.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import UIKit
import DKImagePickerController
import Material

class MediaViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var mediaModel: MediaModel?
    var media: [Media] = [Media](){
        didSet{
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mediaModel = MediaModel(delegate: self)
        
        navigationController?.isMotionEnabled = true
        navigationController?.motionNavigationTransitionType = .autoReverse(presenting: .none)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let pickerController = DKImagePickerController()
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            self.mediaModel?.add(mediaAssets: assets)
        }
        
        self.present(pickerController, animated: true) {}
    }
}

extension MediaViewController: MediaModelDelegate{
    
    func didRecieve(media medias: [Media]) {
        self.media = medias
    }
    
    func didFailWithError(error: Error) {
        print("❌❌❌ - error during fetching data \(error.localizedDescription)")
    }
}


extension MediaViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCollectionViewCell.identifier, for: indexPath) as! MediaCollectionViewCell
        
        let mediaItem = media[indexPath.item]
        
        if let imageKey = mediaItem.urlStr as NSString?{
            if let image = Cache.shared.imageCache.object(forKey: imageKey){
                cell.previewImageView.image = image
            } else {
                mediaItem.getPreviewImage { image in
                    if let img = image{
                        Cache.shared.imageCache.setObject(img, forKey: imageKey)
                        cell.previewImageView.image = img
                        
                    }
                }
            }
        }
        
        cell.previewImageView.motionIdentifier = "photo_\(indexPath.item)"
        cell.configureCell(withMedia: self.media[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailMediaViewController") as? DetailMediaViewController else { return }
        detailVC.media = self.media
        detailVC.scrollToIndexPath = indexPath
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MediaViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let scaleFactor = (screenWidth / 3) - 2
        
        return CGSize(width: scaleFactor, height: scaleFactor)
    }
}
