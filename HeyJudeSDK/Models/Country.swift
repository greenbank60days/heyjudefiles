//
//  Country.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/19.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

public class Country: Decodable, CustomStringConvertible {

    public var iso: String?
    public var iso3: String?
    public var name: String?
    public var numcode: String?
    public var phonecode: String?

    public var description: String {
        var description = "\n*******Country*******\n"
        description += "iso: \(self.iso!)\n"
        description += "iso3: \(self.iso3!)\n"
        description += "name: \(self.name!)\n"
        description += "numcode: \(self.numcode!)\n"
        description += "phonecode: \(self.phonecode!)\n"
        return description
    }

    enum CodingKeys : String, CodingKey {
        case iso
        case iso3
        case name
        case numcode
        case phonecode
    }
}
