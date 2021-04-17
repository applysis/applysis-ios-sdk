//
//  EmptyResponse.swift
//  
//
//  Created by Shalva Avanashvili on 17.04.2021.
//

import Foundation

public struct EmptyResponse: Codable { }

public enum ApplysisError: Error {
    /// Indicates one of the errors: API Key not correct or being invalid
    case forbidden
    case badRequest
    case nonValid
    case unknown(Error?)
}

