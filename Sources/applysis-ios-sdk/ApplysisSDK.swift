//
//  ApplysisSDK.swift
//  
//
//  Created by Shalva Avanashvili on 15.04.2021.
//  Copyright © 2021 Applysis OÜ. All rights reserved.
//

import Foundation
import Combine

public class ApplysisSDK {
    private static var apiKey: String? = nil
    private let key: String
    private let feedbackBatchLimit: Int = 50
    
    public static var shared: ApplysisSDK {
        guard let apiKey = apiKey else {
            fatalError("Applysis SDK must be initialised with apiKey, please use `initialise(with:)` at first.")
        }
        
        return ApplysisSDK(apiKey: apiKey)
    }
    
    private init(apiKey: String) {
        self.key = apiKey
    }
    
    func submitFeedback(_ feedback: Feedback) -> Future<EmptyResponse, ApplysisError> {
        guard feedback.text.isEmpty == false else {
            return Future<EmptyResponse, ApplysisError> { promise in
                promise(.failure(.nonValid))
            }
        }
        
        let request = EndpointBuilder<EmptyResponse>(baseUrl: Links.baseUrl)
            .usingBody([feedback])
            .appendHeader(key: "x-api-key", value: key)
        
        return try! request
            .useHttpMethod(.POST)
            .build()
            .asFuture()
    }
    
    func submitFeedbacks(_ feedbacks: [Feedback]) -> Future<EmptyResponse, ApplysisError>  {
        guard feedbacks.count <= feedbackBatchLimit else {
            return Future<EmptyResponse, ApplysisError> { promise in
                promise(.failure(.nonValid))
            }
        }
        
        let request = EndpointBuilder<EmptyResponse>(baseUrl: Links.baseUrl)
            .usingBody(feedbacks)
            .appendHeader(key: "x-api-key", value: key)
        
        return try! request
            .useHttpMethod(.POST)
            .build()
            .asFuture()
    }
    
    public static func initalise(with apiKey: String) {
        ApplysisSDK.apiKey = apiKey
    }
}
