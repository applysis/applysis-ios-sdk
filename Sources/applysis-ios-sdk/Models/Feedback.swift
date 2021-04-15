//
//  Feedback.swift
//  
//
//  Created by Shalva Avanashvili on 15.04.2021.
//  Copyright © 2021 Applysis OÜ. All rights reserved.
//

import Foundation

public struct Feedback: Codable {
    public let text: String
    public let title: String?
    public let date: Date?
    public let rating: Int?
    public let author: String?
    public let region: String?
    public let version: String?
}
