//
//  FeaturedImage.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/19.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

import UIKit

public class FeaturedImage: Decodable, CustomStringConvertible {

    public var size: Int?
    public var version: Int?
    public var url: String?
    public var isPro: Bool?

    public var description: String {
        var description = "\n*******Featured Image*******\n"
        description += "size: \(self.size!)\n"
        description += "version: \(self.version!)\n"
        description += "url: \(self.url!)\n"
        description += "isPro: \(self.isPro!)\n"
        return description
    }

    enum CodingKeys : String, CodingKey {
        case size
        case version
        case url
        case isPro = "is_pro"
    }
}
