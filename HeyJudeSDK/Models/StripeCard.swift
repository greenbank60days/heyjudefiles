//
//  StripeCard.swift
//  HeyJudeSDK
//
//  Created by Wayne Eldridge on 2019/06/24.
//  Copyright © 2019 TCT Digital. All rights reserved.
//

import Foundation

public class StripeCard: NSObject, Decodable {
    public var last4Digits: String?
    public var expiryMonth, expiryYear: Int?
    
    enum CodingKeys: String, CodingKey {
        case last4Digits = "last4"
        case expiryMonth = "exp_month"
        case expiryYear = "exp_year"
    }
}
