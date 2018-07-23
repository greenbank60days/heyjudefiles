//
//  Vendor.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/20.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

import UIKit

public class Vendor: Decodable, CustomStringConvertible {

    public var name: String?
    public var vendorDescription: String?
    public var address: String?
    public var distance: Int?
    public var rating: Int?
    public var latitude: String?
    public var longitude: String?
    public var text: String?
    public var phone: String?
    public var mobile: String?

    public var description: String {
        var description = "\n*******Vendor*******\n"
        description += "name: \(self.name!)\n"
        description += "vendorDescription: \(self.vendorDescription!)\n"
        description += "address: \(self.address!)\n"
        description += "distance: \(self.distance!)\n"
        description += "rating: \(self.rating!)\n"
        description += "latitude: \(self.latitude!)\n"
        description += "longitude: \(self.longitude!)\n"
        description += "text: \(self.text!)\n"
        description += "phone: \(self.phone!)\n"
        description += "mobile: \(self.mobile!)\n"
        return description
    }

    enum CodingKeys : String, CodingKey {
        case name
        case vendorDescription = "description"
        case address
        case distance
        case rating
        case latitude
        case longitude
        case text
        case phone
        case mobile
    }
}
