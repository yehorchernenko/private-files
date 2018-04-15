//
//  Cache.swift
//  Private Files
//
//  Created by Egor on 15.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import UIKit

class Cache{
    private init(){}
    
    static let shared = Cache()
    var imageCache = NSCache<NSString, UIImage>()
}


