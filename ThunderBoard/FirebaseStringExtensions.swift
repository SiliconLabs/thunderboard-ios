//
//  FirebaseStringExtensions.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

extension String {
    
    func tb_stringByReplacingTokenPairs(replacements: [String:String]) -> String {
        var working = self
        for key in replacements.keys {
            working = working.stringByReplacingOccurrencesOfString(key, withString: replacements[key]!)
        }
        return working
    }
    
    // The following characters are not allowed in Firebase's keys/paths:
    // '.' '#' '$' '[' or ']'
    func tb_sanitizeForFirebase() -> String {
        var working = self
        
        for s in [ "#", ".", "$", "[", "]" ] {
            working = working.stringByReplacingOccurrencesOfString(s, withString: "")
        }
        
        return working
    }
}
