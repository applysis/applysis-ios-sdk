//
//  EmptyResponse.swift
//  
//
//  Created by Shalva Avanashvili on 17.04.2021.
//

import Foundation

struct EmptyResponse: Codable { }

enum ApplysisError: Error {
    /// Indicates one of the errors: API Key not correct or being invalid
    case forbidden
    case badRequest
    case nonValid
    case unknown(Error?)
}

