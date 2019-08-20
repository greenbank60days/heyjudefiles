//
//  Contact.swift
//  HeyJudeSDK
//
//  Created by Andy Whale on 2019/08/16.
//  Copyright © 2019 TCT Digital. All rights reserved.
//

public class ContactCenter: Decodable, CustomStringConvertible {
    
    public var countrycode: String?
    public var contact: String?
    
    public var description: String {
        var description = "\n*******Contact*******\n"
        description += "contact: \(self.contact!)\n"
        description += "country_iso_code: \(self.countrycode!)\n"
        return description
    }
    
    enum CodingKeys : String, CodingKey {
        case countrycode = "country_iso_code"
        case contact
    }
    
}
