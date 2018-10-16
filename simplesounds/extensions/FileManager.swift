//
//  FileManager.swift
//  simplesounds
//
//  Created by Eric Marschner on 10/15/18.
//  Copyright © 2018 Eric Marschner. All rights reserved.
//

import Foundation

extension FileManager {
    var documentDirectory: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return dir!
    }
    var groupDirectory: URL {
        let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.simplesounds.share")
        return dir!
    }
}
