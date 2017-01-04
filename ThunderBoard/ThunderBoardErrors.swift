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
    case urlShorteningRequestCreation
    case urlShorteningNoResponse
    case urlShorteningMissingData
    case urlShorteningInvalidData
    case urlShorteningDeserialization
    case urlShorteningProviderError
    case urlShorteningUnknownError
    
    case streamingDisconnected
}

class ErrorFactory {
    
    //MARK: - URL Shortener
    
    class func shortenerRequestCreationFailure() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.urlShorteningRequestCreation.rawValue, userInfo: [NSLocalizedDescriptionKey : "Invalid Shortening Request"])
    }
    
    class func shortenerNoResponseError() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.urlShorteningNoResponse.rawValue, userInfo: [NSLocalizedDescriptionKey : "No Response"])
    }
    
    class func shortenerMissingDataError() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.urlShorteningMissingData.rawValue, userInfo: [NSLocalizedDescriptionKey : "Empty Response"])
    }
    
    class func shortenerInvalidDataError() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.urlShorteningInvalidData.rawValue, userInfo: [NSLocalizedDescriptionKey : "Invalid Data"])
    }
    
    class func shortenerDeserializationError() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.urlShorteningDeserialization.rawValue, userInfo: [NSLocalizedDescriptionKey : "Malformed Resposne"])
    }
    
    class func shortenerResponseError(_ providerErrorCode: Int) -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.urlShorteningProviderError.rawValue, userInfo: [NSLocalizedDescriptionKey:"Provider Error (\(providerErrorCode))"])
    }
    
    class func shortenerUnknownError() -> NSError {
        return NSError(domain: domainUrlShortener, code: ErrorCodes.urlShorteningUnknownError.rawValue, userInfo: [NSLocalizedDescriptionKey:"Unknown Error"])
    }
    
    //MARK: - Streaming
    
    class func streamingDisconnected() -> NSError {
        return NSError(domain: domainStreaming, code: ErrorCodes.streamingDisconnected.rawValue, userInfo: [NSLocalizedDescriptionKey:"Stream Disconnected"])
    }
}
