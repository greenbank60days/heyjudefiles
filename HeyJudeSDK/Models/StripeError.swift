//
//  StripeError.swift
//  HeyJudeSDK
//
//  Created by Wayne Eldridge on 2019/06/24.
//  Copyright © 2019 TCT Digital. All rights reserved.
//

import Foundation

public class StripeError: NSObject, Decodable {
    public var message: String?
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
