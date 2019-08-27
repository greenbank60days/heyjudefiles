//
//  Reason.swift
//  HeyJudeSDK
//
//  Created by Andy Whale on 2019/08/27.
//  Copyright © 2019 TCT Digital. All rights reserved.
//

import Foundation
public class Reason: Decodable, CustomStringConvertible {
    public var name: String?
    public var rating: Int?
    
    public init () {}
    
    enum CodingKeys : String, CodingKey {
        case name
        case rating
    }
    
    public var description: String {
        var description = "\n*******Reason*******\n"
        description += "name: \(self.name!)\n"
        description += "rating: \(self.rating!)\n"
        return description
    }
}
