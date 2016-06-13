//
//  UrlShortener.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol UrlShortener {
    func shortenUrl(url: String, completion: ((url: String?, error: NSError?) -> Void))
}
