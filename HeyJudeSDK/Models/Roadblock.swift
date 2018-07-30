//
//  Roadblock.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/18.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

public class Roadblock: Decodable, CustomStringConvertible {

    public var identifier: String?
    public var type: String?
    public var priority: Int?

    public var description: String {
        var description = "\n*******Roadblock*******\n"
        description += "identifier: \(self.identifier!)\n"
        description += "type: \(self.type!)\n"
        description += "priority: \(self.priority!)\n"
        return description
    }

    enum CodingKeys : String, CodingKey {
        case identifier
        case type
        case priority
    }
}
