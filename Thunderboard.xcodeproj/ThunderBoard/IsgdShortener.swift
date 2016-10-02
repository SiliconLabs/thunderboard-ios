//
//  IsgdShortener.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class IsgdShortener : UrlShortener {
    
    func shortenUrl(url: String, completion: ((url: String?, error: NSError?) -> Void)) {


        let allowedCharacters = NSCharacterSet.URLQueryAllowedCharacterSet()
        
        guard let escapedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters) else {
            log.error("Failed to escape URL \(url)")
            completion(url: nil, error: ErrorFactory.shortenerRequestCreationFailure())
            return
        }

        guard let requestUrl = NSURL(string: "https://is.gd/create.php?format=json&url=\(escapedUrl)") else {
            log.error("Failed to create request URL for shortener")
            completion(url: nil, error: ErrorFactory.shortenerRequestCreationFailure())
            return
        }
        
        let request = NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = "POST"

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in

            // is.gd returns 200 even when there are errors - need to parse the body
            // { "errorcode": 1, "errormessage": "Please enter a valid URL to shorten" }

            // Error code 1 - there was a problem with the original long URL provided
            // Error code 2 - there was a problem with the short URL provided (for custom short URLs)
            // Error code 3 - our rate limit was exceeded (your app should wait before trying again)
            // Error code 4 - any other error (includes potential problems with our service such as a maintenance period)

            guard let httpResponse = response as! NSHTTPURLResponse? else {
                log.error("API did not respond to request")
                return completion(url: nil, error: ErrorFactory.shortenerNoResponseError())
            }
            
            guard let jsonData = data else {
                completion(url:nil, error: ErrorFactory.shortenerInvalidDataError())
                return
            }

            if httpResponse.statusCode != 200 {
                log.error("Unexpected HTTP response from shortener API: \(httpResponse.statusCode)")
                completion(url: nil, error: ErrorFactory.shortenerResponseError(httpResponse.statusCode))
            }

            do {
                let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0)) as! Dictionary<String, AnyObject>

                if let errorCode = json["errorcode"] as! Int? {
                    log.error("is.gd returned internal error code \(errorCode)")
                    let error = ErrorFactory.shortenerResponseError(errorCode)
                    completion(url: nil, error: error)
                }
                    
                else if let shortUrl = json["shorturl"] as! String? {
                    completion(url: shortUrl, error: nil)
                }
                    
                else {
                    let error = ErrorFactory.shortenerInvalidDataError()
                    completion(url: nil, error: error)
                }
            }
            catch {
                completion(url: nil, error: ErrorFactory.shortenerDeserializationError())
            }

        }
        
        task.resume()
    }
    
}
