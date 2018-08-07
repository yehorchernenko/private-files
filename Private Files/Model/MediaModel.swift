//
//  MediaModel.swift
//  Private Files
//
//  Created by Egor on 14.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import DKImagePickerController
import Photos


class MediaModel{
    
    private var moc: NSManagedObjectContext{
        return NSManagedObjectContext.shared
    }
    
    weak var delegate: MediaModelDelegate?
    
    let dispatchGroup = DispatchGroup()
    
    init(delegate: MediaModelDelegate) {
        self.delegate = delegate
        
        requestData()
    }
    
    private func requestData(){
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do{
            let media = try moc.fetch(fetchRequest)
            self.delegate?.didRecieve(media: media)
        } catch {
            self.delegate?.didFailWithError(error: error)
        }
    }
    
    func add(mediaAssets assets: [DKAsset]){
        for asset in assets{
            let date = Date()
            let newMedia = Media(context: self.moc)
            newMedia.date = date
            
            dispatchGroup.enter()
            saveAssetToDocDir(asset: asset, date: date, completion: { [weak self] urlStr in
                newMedia.assetType = asset.isVideo ? AssetType.video.rawValue : AssetType.photo.rawValue
                newMedia.urlStr = urlStr
                try? self?.moc.save()
                self?.dispatchGroup.leave()
            })
            
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.requestData()
        }
    }
    
    
    private func saveAssetToDocDir(asset: DKAsset, date: Date,completion : @escaping (String) -> ()){
        
        DispatchQueue.global(qos: .userInitiated).async {
            let documentsDirectory = URL.documentDirectory
            let fileName = "\(date)\(arc4random())"
            
            if asset.isVideo{
                let options = PHVideoRequestOptions()
                options.version = .original
                
                if let phAsset = asset.originalAsset{
                    PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options, resultHandler: { (vAsset, audioMix, info) in
                        if vAsset is AVURLAsset{
                            let url = (vAsset as? AVURLAsset)?.url
                            if let anUrl = url{
                                if let videoData = try? Data(contentsOf: anUrl){
                                    
                                    let fileURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("mov")
                                    
                                    try! videoData.write(to: fileURL)
                                    
                                    DispatchQueue.main.async {
                                        completion(fileName + ".mov")
                                    }
                                    
                                    
                                }
                            }
                        }
                        
                    })
                }
                
            } else {
                let options = PHImageRequestOptions()
                options.resizeMode = .exact
                options.deliveryMode = .highQualityFormat
                options.isSynchronous = true
                
                if let iAsset = asset.originalAsset{
                    PHImageManager.default().requestImage(for: iAsset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options, resultHandler: { (image, info) in
                        
                        if let imageData = UIImageJPEGRepresentation(image!, 1.0){
                            
                            let fileURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("jpeg")
                            try! imageData.write(to: fileURL)
                            
                            DispatchQueue.main.async {
                                completion(fileName + ".jpeg")
                            }
                            
                        }
                    })
                }
                
            }
            
        }
        }
        
}

enum AssetType: String {
    case video = "video"
    case photo = "photo"
}

