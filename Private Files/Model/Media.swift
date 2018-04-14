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

    func getPreviewImage(completion: @escaping (UIImage?) -> ()){
        guard let filePath = self.urlStr else {return}
        let documentsDirectory = URL.documentDirectory
        
        DispatchQueue.global(qos: .userInteractive).async {
            if self.assetType == AssetType.video.rawValue{
                let fileURL = documentsDirectory.appendingPathComponent(filePath)
                let asset = AVAsset(url: fileURL)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                do{
                    let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                    let image = UIImage(cgImage: cgImage)
                    
                    DispatchQueue.main.async {
                        completion(image)
                    }
                
                } catch {
                    print(error.localizedDescription)
                }
                
            } else {
                
                let fileURL = documentsDirectory.appendingPathComponent(filePath)
                let image = UIImage(contentsOfFile: fileURL.path)
            
                DispatchQueue.main.async {
                    completion(image)
                }
            
            }
        }

    
    }
    
    
    
}

protocol MediaItem {
    func getPreviewImage(completion: @escaping (UIImage?) -> ())
    var assetType: String? {get}
}
