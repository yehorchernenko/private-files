//
//  URL + doc dir.swift
//  Private Files
//
//  Created by Egor on 14.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import Foundation

extension URL {
    static var documentDirectory: URL{
        let fileManger = FileManager.default
        let documentsDirectory = try! fileManger.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        return documentsDirectory
    }
}
