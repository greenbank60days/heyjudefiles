//
//  Contact.swift
//  HeyJudeSDK
//
//  Created by Andy Whale on 2019/08/16.
//  Copyright © 2019 TCT Digital. All rights reserved.
//

public class ContactCenter: Decodable, CustomStringConvertible {
    
    public var countrycode: String?
    public var contactnumber: String?
    
    public var description: String {
        var description = "\n*******Contact*******\n"
        description += "countrycode: \(self.countrycode!)\n"
        description += "contactnumber: \(self.contactnumber!)\n"
        return description
    }
    
    enum CodingKeys : String, CodingKey {
        case countrycode
        case contactnumber
    }
    
}
