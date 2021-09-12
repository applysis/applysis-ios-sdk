//
//  Feedback.swift
//  
//
//  Created by Shalva Avanashvili on 15.04.2021.
//  Copyright © 2021 Applysis OÜ. All rights reserved.
//

import Foundation

public struct Feedback: Codable {
    public let text: String?
    public let title: String?
    public let date: Date?
    public let rating: Int?
    public let author: String?
    public let region: String?
    public let version: String?
    public let tags: [String]?
    
    public init(
        text: String,
        title: String?,
        date: Date?,
        rating: Int?,
        author: String?,
        region: String?,
        version: String?,
        tags: [String]?
    ) {
        self.text = text
        self.title = title
        self.date = date
        self.rating = rating
        self.author = author
        self.region = region
        self.version = version
        self.tags = tags
    }
}
