//
//  Media.swift
//  Private Files
//
//  Created by Egor on 14.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import AVFoundation

extension Media: MediaItem{
    var previewImage: UIImage?{
        guard let filePath = self.urlStr else {return nil}
        let documentsDirectory = URL.documentDirectory
        
        if self.assetType == AssetType.video.rawValue{
            let fileURL = documentsDirectory.appendingPathComponent(filePath)
            let asset = AVAsset(url: fileURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            do{
                let image = try imageGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                return UIImage(cgImage: image)
            } catch {
                print(error.localizedDescription)
            }
            
        } else {
            
            let fileURL = documentsDirectory.appendingPathComponent(filePath)
            return UIImage(contentsOfFile: fileURL.path)
            
            
        }
        
        return nil
        
    }
    
    
    
}

protocol MediaItem {
    var previewImage: UIImage? {get}
    var assetType: String? {get}
}
