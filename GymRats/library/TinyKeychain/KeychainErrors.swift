//
//  KeychainErrors.swift
//  TinyKeychain
//
//  Created by Swain Molster on 5/9/18.
//  Copyright © 2018 Swain Molster. All rights reserved.
//

import Foundation

extension Keychain {
    
    /// Represents an `Error` arising from attempting to store an object into a `Keychain`.
    enum StoringError: Error, CustomStringConvertible, CustomDebugStringConvertible {
        
        /// A keychain-level error resulting from storage attempt.
        case couldNotStore(keyRawValue: String, OSStatus)
        
        /// An `Error` resulting from attempt to encode. This will usually be an `EncodingError`, but Swift's error handling provides no guarantee.
        case encodingError(Error)
        
         var localizedDescription: String {
            return description
        }
        
         var description: String {
            return debugDescription
        }
        
         var debugDescription: String {
            switch self {
            case .couldNotStore(keyRawValue: let keyRawValue, let status):
                return "Issue storing to keychain using key with raw value: \(keyRawValue). OSStatus: \(status)"
            case .encodingError(let error):
                guard let encodingError = error as? EncodingError else {
                    return "Error arose during encoding that wasn't an `EncodingError`. Localized description: \(error.localizedDescription)"
                }
                
                var string = "Encoding Error: <TYPE>"
                let errorType: String
                switch encodingError {
                case .invalidValue(_, let context):
                    errorType = "Invalid Value"
                    string += "\nContext: \(context.debugDescription)\nCoding Path: \(context.codingPath)"
                }
                return string.replacingOccurrences(of: "<TYPE>", with: errorType)
            }
        }
    }
    
    /// Represents an `Error` arising from attempting to retrieve an object from a `Keychain`.
     enum RetrievalError: Error, CustomStringConvertible, CustomDebugStringConvertible {
        
        /// A keychain-level error resulting from retrieval attempt.
        case couldNotRetrieve(keyRawValue: String, OSStatus)
        
        /// An `Error` resulting from attempt to decode the object found in the keychain. This will usually be a `DecodingError`, but Swift's error handling provides no guarantee.
        case decodingError(Error)
        
        /// Could not find an object in the keychain for the provided key.
        case objectNotFound(keyRawValue: String)
        
         var localizedDescription: String {
            return description
        }
        
         var description: String {
            return debugDescription
        }
        
         var debugDescription: String {
            switch self {
            case .objectNotFound(keyRawValue: let keyRawValue):
                return "Object not found in keychain for key with raw value: \(keyRawValue)."
            case .decodingError(let error):
                guard let decodingError = error as? DecodingError else {
                    return "Error arose during decoding that wasn't a `DecodingError`. Localized description: \(error.localizedDescription)"
                }
                
                var string = "Decoding Error: <TYPE>"
                let errorType: String
                switch decodingError {
                case .dataCorrupted(let context):
                    errorType = "Data Corrupted"
                    string += "\nContext: \(context.debugDescription)\nCoding Path: \(context.codingPath)"
                case .keyNotFound(let codingKey, let context):
                    errorType = "Key Not Found"
                    string += "\nContext: \(context.debugDescription)\nCoding Path: \(context.codingPath)\nBad Key: \(codingKey)"
                case .typeMismatch(let type, let context):
                    errorType = "Type Mismatch"
                    string += "\nContext: \(context.debugDescription)\nCoding Path: \(context.codingPath)\nType: \(type)"
                case .valueNotFound(let type, let context):
                    errorType = "Value Not Found"
                    string += "\nContext: \(context.debugDescription)\nCoding Path: \(context.codingPath)\nType: \(type)"
                }
                return string.replacingOccurrences(of: "<TYPE>", with: errorType)
                
            case .couldNotRetrieve(keyRawValue: let keyRawValue, let status):
                return "Issue retrieving from keychain using key with raw value: \(keyRawValue). OSStatus: \(status)"
            }
        }
    }
    
    /// Represents an `Error` arising from attempting to delete an object from a `Keychain`.
    enum DeletionError: Error, CustomStringConvertible, CustomDebugStringConvertible {
        
        /// A keychain-level error resulting from deletion attempt.
        case couldNotDelete(keyRawValue: String, OSStatus)
        
         var localizedDescription: String {
            return description
        }
        
         var description: String {
            return debugDescription
        }
        
         var debugDescription: String {
            switch self {
            case .couldNotDelete(keyRawValue: let keyRawValue, let status):
                return "Issue deleting value from keychain using key with raw value: \(keyRawValue). OSStatus: \(status)"
            }
        }
    }
}
