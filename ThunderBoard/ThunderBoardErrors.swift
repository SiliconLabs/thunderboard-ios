//
//  ErrorTypes.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

let domainUrlShortener  = "com.silabs.Thunderboard.urlshortening"
let domainStreaming     = "com.silabs.Thunderboard.streaming"

enum ErrorCodes: Int {
    case UrlShorteningRequestCreation
    case UrlShorteningNoResponse
    case UrlShorteningMissingData
    case UrlShorteningInvalidData
    case UrlShorteningDeserialization
    case UrlShorteningProviderError
    case UrlShorteningUnknownError
    
    case StreamingDisconnected
}

class ErrorFactory {
    
    //MARK: - URL Shortener
    
    class func shortenerRequestCreationFailure() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.UrlShorteningRequestCreation.rawValue, userInfo: [NSLocalizedDescriptionKey : "Invalid Shortening Request"])
    }
    
    class func shortenerNoResponseError() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.UrlShorteningNoResponse.rawValue, userInfo: [NSLocalizedDescriptionKey : "No Response"])
    }
    
    class func shortenerMissingDataError() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.UrlShorteningMissingData.rawValue, userInfo: [NSLocalizedDescriptionKey : "Empty Response"])
    }
    
    class func shortenerInvalidDataError() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.UrlShorteningInvalidData.rawValue, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])
    }
    
    class func shortenerDeserializationError() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.UrlShorteningDeserialization.rawValue, userInfo: [NSLocalizedDescriptionKey : "Malformed Resposne"])
    }
    
    class func shortenerResponseError(providerErrorCode: Int) -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.UrlShorteningProviderError.rawValue, userInfo: [NSLocalizedDescriptionKey:"Provider Error (\(providerErrorCode))"])
    }
    
    class func shortenerUnknownError() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.UrlShorteningUnknownError.rawValue, userInfo: [NSLocalizedDescriptionKey:"Unknown Error"])
    }
    
    //MARK: - Streaming
    
    class func streamingDisconnected() -> NSError {
        return NSError(domain: domainStreaming, code: ErrorCodes.StreamingDisconnected.rawValue, userInfo: [NSLocalizedDescriptionKey:"Stream Disconnected"])
    }
}