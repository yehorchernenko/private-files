//
//  DetailMediaViewController.swift
//  Private Files
//
//  Created by Egor on 14.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import UIKit
import Photos
import AVKit

class DetailMediaViewController: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    class var segueIdentifier: String {
        return String(describing: self)
    }
    
    var mediaModel: MediaModel?
    var media: [Media] = []
    var scrollToIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let indexPath = self.scrollToIndexPath{
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.scrollToIndexPath = nil
            
        }
    }
    
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let media = (self.collectionView.visibleCells[self.collectionView.visibleCells.count/2] as? MediaCollectionViewCell)?.media, let urlStr = media.urlStr else {return}
        let url = URL.documentDirectory.appendingPathComponent(urlStr)
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.openInIBooks, UIActivityType.print]
            self.present(activityViewController, animated: true, completion: nil)
        case .restricted, .denied:
            let libraryRestrictedAlert = UIAlertController(title: "Photos access denied",
                                                           message: "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots.",
                                                           preferredStyle: UIAlertControllerStyle.alert)
            libraryRestrictedAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(libraryRestrictedAlert, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .authorized {
                    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.openInIBooks, UIActivityType.print]
                    self.present(activityViewController, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        let alertScreen = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete media", style: .destructive) { [weak self] action in
            guard let strongSelf = self else { return }
            guard let visibleCell = strongSelf.collectionView.visibleCells.first else { return }
            guard let indexPath = strongSelf.collectionView.indexPath(for: visibleCell) else { return }
            
            strongSelf.mediaModel?.delete(media: strongSelf.media[indexPath.item])
            strongSelf.media.remove(at: indexPath.item)
            strongSelf.collectionView.deleteItems(at: [indexPath])
        }
        alertScreen.addAction(cancelAction)
        alertScreen.addAction(deleteAction)
        present(alertScreen, animated: true, completion: nil)
    }
    
}

extension DetailMediaViewController: UICollectionViewDelegate, UICollectionViewDataSource{
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
                //TODO: - FIX BUG HERE
                mediaItem.getPreviewImage { image in
                    if let img = image{
                        Cache.shared.imageCache.setObject(img, forKey: imageKey)
                        cell.previewImageView.image = img
                    }
                }
            }
        }
        
        cell.configureCell(withMedia: mediaItem, motionId: "photo_\(indexPath.item)")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.media[indexPath.item].assetType == AssetType.video.rawValue{
            if let urlStr = self.media[indexPath.item].urlStr{
                let url = URL.documentDirectory.appendingPathComponent(urlStr)
                let videoPlayer = AVPlayer(url: url)
                let videoController = AVPlayerViewController()
                videoController.player = videoPlayer
                
                videoController.modalPresentationStyle = .overCurrentContext
                videoController.modalTransitionStyle = .crossDissolve
                self.present(videoController, animated: true, completion: {
                    videoPlayer.play()
                })
            }
        } else {
            navigationController!.navigationBar.isHidden = !navigationController!.navigationBar.isHidden
            view.backgroundColor = view.backgroundColor == .white ? .black : .white
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let date = self.media[indexPath.item].date else { return }
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MMM d, yyyy, hh:mm a"
        dateFormater.amSymbol = "AM"
        dateFormater.pmSymbol = "PM"
        navigationItem.title = dateFormater.string(from: date)
        
    }
    
}

extension DetailMediaViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.bounds.size
    }
}
