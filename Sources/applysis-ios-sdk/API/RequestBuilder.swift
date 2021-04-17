//
//  RequestBuilder.swift
//
//
//  Created by Shalva Avanashvili on 15.04.2021.
//  Copyright © 2021 Applysis OÜ. All rights reserved.
//

import Foundation
import Combine

struct Pair {
    let key: String
    let value: String
}

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

class RequestBuilder<T: Decodable> {
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let requestURL: URL
    
    private var request: URLRequest!
    private var logLevel: NetworkLogLevel = .none
    private var headers: [Pair] = []
    private var method: HTTPMethod = .POST
    private var httpBody: Data? = nil
    
    init(baseUrl: String) {
        requestURL = URL(string: baseUrl)!
    }
    
    /// Sets the custom header for the request
    /// - Parameters:
    ///   - key: header key
    ///   - value: header value
    /// - Returns: RequestBuilder
    @discardableResult func appendHeader(key: String, value: String) -> RequestBuilder {
        headers.append(Pair(key: key, value: value))
        
        return self
    }
    
    /// Sets the request http method
    /// - Parameter method: value of the method e.g POST, GET etc
    /// - Returns: RequestBuilder
    @discardableResult func useHttpMethod(_ method: HTTPMethod) -> RequestBuilder {
        self.method = method
        
        return self
    }
    
    /// Sets the body for the RequestBuilder
    /// - Parameter body: Body
    /// - Returns: RequestBuilder
    @discardableResult func useBody<T: Encodable>(_ body: T) -> RequestBuilder {
        httpBody = try? jsonEncoder.encode(body)
        return self
    }
    
    /// Sets custom date formatter strategy
    /// - Parameter formatter: date formmatter, how the date should be exctracted form the response
    /// - Returns: RequestBuilder
    @discardableResult func useDateEncodingStrategy(_ formatter: DateFormatter) -> RequestBuilder {
        jsonEncoder.dateEncodingStrategy = .formatted(formatter)
        return self
    }
    
    /// Sets custom date formatter strategy
    /// - Parameter level: Networking logging level
    /// - Returns: RequestBuilder
    @discardableResult func useLoggingLevel(_ level: NetworkLogLevel) -> RequestBuilder {
        logLevel = level
        return self
    }
    
    /// Builds the request based on all builder methods
    /// - Returns: Future of the request
    func build() ->  Future<T, ApplysisError> {
        request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        headers.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        request.httpBody = httpBody
        
        
        Logger.log(level: logLevel, request: request)
        
        return Future<T, ApplysisError> { promise in
            let task = URLSession.shared.dataTask(with: self.request) { data, response, error in
                guard let response = response as? HTTPURLResponse else {
                    promise(.failure(.unknown(error)))
                    return
                }
                
                guard response.statusCode == 200 else {
                    switch response.statusCode {
                    case 403:
                        promise(.failure(.forbidden))
                    case 400:
                        promise(.failure(.badRequest))
                    default:
                        promise(.failure(.unknown(error)))
                    }
                    
                    return
                }
                
                do {
                    Logger.log(level: self.logLevel, response: response, data: data!.valid)
                    promise(.success(try self.jsonDecoder.decode(T.self, from: data!.valid)))
                } catch let error {
                    promise(.failure(.unknown(error)))
                }
            }
            
            task.resume()
        }
    }
}

private extension Data {
    var valid: Data {
        if isEmpty {
            return "{}".data(using: .utf8)!
        }
        return self
    }
}

