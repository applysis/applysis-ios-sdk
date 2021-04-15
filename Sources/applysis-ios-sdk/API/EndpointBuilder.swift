//
//  Endpoint.swift
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

class EndpointBuilder<Response: Decodable> {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var request: URLRequest!
    
    private let url: URL
    
    private var headers: [Pair] = []
    private var method: HTTPMethod = .POST
    private var httpBody: Data? = nil
    
    init(baseUrl: String) {
        url = URL(string: baseUrl)!
    }
    
    /// Sets the custom header for the request
    /// - Parameters:
    ///   - key: header key
    ///   - value: header value
    /// - Returns: Endpoint
    @discardableResult func appendHeader(key: String, value: String) -> EndpointBuilder {
        headers.append(Pair(key: key, value: value))
        
        return self
    }
    
    /// Sets the request http method
    /// - Parameter method: value of the method e.g POST, GET etc
    /// - Returns: Endpoint
    @discardableResult func useHttpMethod(_ method: HTTPMethod) -> EndpointBuilder {
        self.method = method
        
        return self
    }
    
    /// Sets the User-Agent header value
    /// - Parameter userAgent: value of the User-Agent header
    /// - Returns: Endpoint
    @discardableResult func useUserAgent(_ userAgent: String) -> EndpointBuilder {
        self.headers.append(Pair(key: "User-Agent", value: userAgent))
        
        return self
    }
    
    /// Sets Content-Type header value
    /// - Parameter mimeType: value of the mimeType
    /// - Returns: Endpoint
    @discardableResult func useContentType(_ mimeType: String) -> EndpointBuilder {
        self.headers.append(Pair(key: "Content-Type", value: mimeType))
        return self
    }
    
    /// Sets the body for the Endpoint
    /// - Parameter body: Body
    /// - Returns: Endpoint
    @discardableResult func usingBody<T: Encodable>(_ body: T) -> EndpointBuilder {
        httpBody = try? encoder.encode(body)
        return self
    }
    
    /// Sets custom date formatter strategy
    /// - Parameter formatter: date formmatter, how the date should be exctracted form the response
    /// - Returns: Endpoint
    @discardableResult func useDateDecodingStrategy(_ formatter: DateFormatter) -> EndpointBuilder {
        decoder.dateDecodingStrategy = .formatted(formatter)
        return self
    }
    
    /// Builds the request based on all builder methods
    /// - Throws: Throws the exception, if the endpoint is malformed
    /// - Returns: Endpoint
    @discardableResult func build() throws -> EndpointBuilder {
        request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        request.httpBody = httpBody
        
        return self
    }
    
    func asFuture() -> Future<Response, ApplysisError> {
        return Future<Response, ApplysisError> { promise in
            let task = URLSession.shared.dataTask(with: self.request) { data, response, error in
                guard let response = response as? HTTPURLResponse else {
                    promise(.failure(.unknown(error)))
                    return
                }
                
                switch response.statusCode {
                case 403:
                    promise(.failure(.forbidden))
                case 400:
                    promise(.failure(.badRequest))
                default:
                    promise(.failure(.unknown(error)))
                }
            
                guard error == nil else {
                    promise(.failure(.unknown(error)))
                    return
                }
                
                do {
                    promise(.success(try self.decoder.decode(Response.self, from: data!.valid)))
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
