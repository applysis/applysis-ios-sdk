
//
//  ApplysisLogger.swift
//
//
//  Created by Shalva Avanashvili on 17.04.2021.
//  Copyright © 2021 Applysis OÜ. All rights reserved.
//

import Foundation

enum NetworkLogLevel: Int {
    case info
    case none
}

public class ApplysisLogger {
    static func log(level: NetworkLogLevel, request: URLRequest) {
        guard level != .none else { return }
        
        let method = request.httpMethod ?? ""
        let url = request.url?.absoluteString
        let headers = request.allHTTPHeaderFields ?? [:]

        var params: [Any] = ["📤 Request"]
        params.append("HTTPMethod   -> \(method)")
        params.append("URL          -> \(url ?? "")")
        params.append(
            "Headers      -> [\(headers.map { "\($0.key): \($0.value)" }.joined(separator: ",\n                "))]"
        )
        
        if let body = request.httpBody {
            let decodedBody = String(decoding: body, as: UTF8.self)
            params.append("Body         -> \(decodedBody)")
        }
        
        trace(level: level, params: params)
    }
    
    static func log(level: NetworkLogLevel, response: URLResponse?, data: Data) {
        guard level != .none else { return }
        
        let url = response?.url?.absoluteString
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        var params: [Any] = ["📤 Response"]
        params.append("URL          -> \(url ?? "")")
        params.append("Response     -> \(json ?? [:])")

        trace(level: level, params: params)
    }
    
    
    static func trace(level: NetworkLogLevel, params: [Any]) {
        #if DEBUG
        
        let heading: String
        switch level {
            case .info:
                heading = "✅ NETWORKING INFO"
            default:
                heading = "✉️ NETWORKING MESSAGE"
        }
        
        print("\(heading)")
        for param in params {
            print("\(String(describing: param))")
        }
        print("⏰ - \(Date())")
        print("\n")
        
        #endif
    }
}


