//
//  Applysis.swift
//  
//
//  Created by Shalva Avanashvili on 15.04.2021.
//  Copyright © 2021 Applysis OÜ. All rights reserved.
//

import Foundation
import Combine

public class Applysis {
    private static var apiKey: String? = nil
    
    private let key: String
    private let feedbackBatchLimit: Int = 50
    private var debugModeEnabled = false
    
    private static var sdk: Applysis?
    public static var shared: Applysis {
        guard let sdk = sdk else {
            fatalError("Applysis SDK must be initialised with apiKey, please use `initialise(with:)` at first.")
        }
        
        return sdk
    }
    
    public static func initalise(with apiKey: String) {
        sdk = Applysis(apiKey: apiKey)
    }
    
    private init(apiKey: String) {
        self.key = apiKey
    }
    
    public func enableDebugMode() {
        self.debugModeEnabled = true
    }
    
    public func disableDebugMode() {
        self.debugModeEnabled = false
    }
    
    public func submitFeedback(_ feedback: Feedback) -> Future<EmptyResponse, ApplysisError> {
        guard feedback.text.isEmpty == false else {
            return Future<EmptyResponse, ApplysisError> { promise in
                promise(.failure(.nonValid))
            }
        }
        
        var request = RequestBuilder<EmptyResponse>(baseUrl: Links.baseUrl)
            .useHttpMethod(.POST)
            .useDateEncodingStrategy(.iso3339Formatter)
            .useBody([feedback])
            .appendHeader(key: "x-api-key", value: key)
            .appendHeader(key: "Content-Type", value: "application/json")
        
        if debugModeEnabled {
            request = request.useLoggingLevel(.info)
        }
        
        return request.build()
    }
    
    public func submitFeedbacks(_ feedbacks: [Feedback]) -> Future<EmptyResponse, ApplysisError>  {
        guard feedbacks.count <= feedbackBatchLimit else {
            return Future<EmptyResponse, ApplysisError> { promise in
                promise(.failure(.nonValid))
            }
        }
        
        var request = RequestBuilder<EmptyResponse>(baseUrl: Links.baseUrl)
            .useHttpMethod(.POST)
            .useDateEncodingStrategy(.iso3339Formatter)
            .useBody(feedbacks)
            .appendHeader(key: "x-api-key", value: key)
            .appendHeader(key: "Content-Type", value: "application/json")
        
        if debugModeEnabled {
            request = request.useLoggingLevel(.info)
        }
        
        return request.build()
    }
}

public extension DateFormatter {
    static var iso3339Formatter: DateFormatter {
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        fullDateFormatter.locale = Locale(identifier: "en_GB")
        return fullDateFormatter
    }
}
