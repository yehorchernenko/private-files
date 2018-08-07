//
//  Cache.swift
//  Private Files
//
//  Created by Egor on 15.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import UIKit

class Cache{
    private init(){
        imageCache.totalCostLimit = 100_000_000
    }
    
    static let shared = Cache()
    var imageCache = NSCache<NSString, UIImage>()
    
}
