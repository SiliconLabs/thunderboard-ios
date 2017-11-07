//
//  UrlShortener.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol UrlShortener {
    func shortenUrl(_ url: String, completion: @escaping ((_ url: String?, _ error: Error?) -> Void))
}
