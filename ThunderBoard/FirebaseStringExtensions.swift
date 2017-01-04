//
//  FirebaseStringExtensions.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

extension String {
    
    func tb_stringByReplacingTokenPairs(_ replacements: [String:String]) -> String {
        var working = self
        for key in replacements.keys {
            working = working.replacingOccurrences(of: key, with: replacements[key]!)
        }
        return working
    }
    
    // The following characters are not allowed in Firebase's keys/paths:
    // '.' '#' '$' '[' or ']'
    func tb_sanitizeForFirebase() -> String {
        var working = self
        
        for s in [ "#", ".", "$", "[", "]" ] {
            working = working.replacingOccurrences(of: s, with: "")
        }
        
        return working
    }
}
