//
//  Idea.swift
//  HeyJudeSDK
//
//  Created by Andy Whale on 2019/08/12.
//  Copyright © 2019 TCT Digital. All rights reserved.
//

import Foundation

public class Idea: Decodable, CustomStringConvertible {
    public var id: Int?
    public var key: String?
    public var name: String?
    public var template: String?
    public var descriptionText: String?
    public var icon: String?
    
    public init () {}
    
    enum CodingKeys : String, CodingKey {
        case id
        case key
        case name
        case template
        case descriptionText = "description"
        case icon
    }
    
    public var description: String {
        var description = "\n*******Idea*******\n"
        description += "id: \(self.id!)\n"
        description += "key: \(self.key!)\n"
        description += "name: \(self.name!)\n"
        description += "description: \(self.descriptionText!)\n"
        description += "icon: \(self.icon!)\n"
        return description
    }
}
