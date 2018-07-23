//
//  Response.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/15.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

import UIKit

public class Response: NSObject, Decodable {

    public var errors: [String]?
    public var token: String?
    public var message: String?
    public var success: Bool?

    enum CodingKeys : String, CodingKey {
        case errors
        case token
        case message
        case success
    }

}
