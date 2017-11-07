//
//  IsgdShortener.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class IsgdShortener : UrlShortener {
    
    func shortenUrl(_ url: String, completion: @escaping ((_ url: String?, _ error: Error?) -> Void)) {


        let allowedCharacters = CharacterSet.urlQueryAllowed
        
        guard let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            log.error("Failed to escape URL \(url)")
            completion(nil, ErrorFactory.shortenerRequestCreationFailure())
            return
        }

        guard let requestUrl = URL(string: "https://is.gd/create.php?format=json&url=\(escapedUrl)") else {
            log.error("Failed to create request URL for shortener")
            completion(nil, ErrorFactory.shortenerRequestCreationFailure())
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in

            // is.gd returns 200 even when there are errors - need to parse the body
            // { "errorcode": 1, "errormessage": "Please enter a valid URL to shorten" }

            // Error code 1 - there was a problem with the original long URL provided
            // Error code 2 - there was a problem with the short URL provided (for custom short URLs)
            // Error code 3 - our rate limit was exceeded (your app should wait before trying again)
            // Error code 4 - any other error (includes potential problems with our service such as a maintenance period)

            guard let httpResponse = response as! HTTPURLResponse? else {
                log.error("API did not respond to request")
                return completion(nil, ErrorFactory.shortenerNoResponseError())
            }
            
            guard let jsonData = data else {
                completion(nil, ErrorFactory.shortenerInvalidDataError())
                return
            }

            if httpResponse.statusCode != 200 {
                log.error("Unexpected HTTP response from shortener API: \(httpResponse.statusCode)")
                completion(nil, ErrorFactory.shortenerResponseError(httpResponse.statusCode))
            }

            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! Dictionary<String, AnyObject>

                if let errorCode = json["errorcode"] as! Int? {
                    log.error("is.gd returned internal error code \(errorCode)")
                    let error = ErrorFactory.shortenerResponseError(errorCode)
                    completion(nil, error)
                }
                    
                else if let shortUrl = json["shorturl"] as! String? {
                    completion(shortUrl, nil)
                }
                    
                else {
                    let error = ErrorFactory.shortenerInvalidDataError()
                    completion(nil, error)
                }
            }
            catch {
                completion(nil, ErrorFactory.shortenerDeserializationError())
            }

        }) 
        
        task.resume()
    }
    
}
