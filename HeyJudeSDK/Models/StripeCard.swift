//
//  StripeCard.swift
//  HeyJudeSDK
//
//  Created by Wayne Eldridge on 2019/06/24.
//  Copyright © 2019 TCT Digital. All rights reserved.
//

import Foundation

public class StripeCard: NSObject, Decodable {
    public var lastFourDigits, brand: String?
    public var expiryMonth, expiryYear: Int?
    
    enum CodingKeys: String, CodingKey {
        case brand
        case lastFourDigits = "last4"
        case expiryMonth = "exp_month"
        case expiryYear = "exp_year"
    }
}
