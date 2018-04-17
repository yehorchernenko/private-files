//
//  MediaViewController.swift
//  Private Files
//
//  Created by Egor on 14.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import UIKit
import DKImagePickerController


class MediaViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var mediaModel: MediaModel?
    var media: [Media] = [Media](){
        didSet{
            self.collectionView.reloadData()
        }
    }
    var imageFrame: CGRect?
    var selectedImage: UIImageView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(cellDidChangedInAnotherController(notification:)), name: .cellDidChange, object: nil)
        self.navigationController?.delegate = self
        mediaModel = MediaModel(delegate: self)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let pickerController = DKImagePickerController()
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            self.mediaModel?.add(mediaAssets: assets)
        }
        
        self.present(pickerController, animated: true) {}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailMediaViewController{
            vc.media = self.media
            vc.scrollToIndexPath = sender as? IndexPath
            
        }
    }
    
    @objc func cellDidChangedInAnotherController(notification: Notification){
        guard let indexPath = notification.userInfo!["indexPath"] as? IndexPath else { return }
        self.selectedImage = (collectionView.cellForItem(at: indexPath) as! MediaCollectionViewCell).previewImageView
        self.imageFrame = self.selectedImage!.superview!.convert(selectedImage!.frame, to: nil)
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
        
        
        cell.configureCell(withMedia: self.media[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = (collectionView.cellForItem(at: indexPath) as! MediaCollectionViewCell).previewImageView
        self.imageFrame = self.selectedImage!.superview!.convert(selectedImage!.frame, to: nil)
        performSegue(withIdentifier: DetailMediaViewController.segueIdentifier, sender: indexPath)

    }
}

extension MediaViewController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{

        
        
        guard let originFrame = self.imageFrame else { return nil }
        switch operation {
        case .push:
            return PushAnimator(duration: 0.3, presenting: true, originFrame: originFrame)
        default:
            return PushAnimator(duration: 0.3, presenting: false, originFrame: originFrame)
        }
        
    }
}

extension MediaViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let scaleFactor = (screenWidth / 3) - 2
        
        return CGSize(width: scaleFactor, height: scaleFactor)
    }
}
