//
//  MediaModelDelegate.swift
//  Private Files
//
//  Created by Egor on 14.04.2018.
//  Copyright © 2018 Chernenko Inc. All rights reserved.
//

import Foundation

protocol MediaModelDelegate: class {
    func didRecieve(medias: [Media])
    func didFailWithError(error: Error)
}
