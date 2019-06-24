//
//  StripeReponse.swift
//  HeyJudeSDK
//
//  Created by Wayne Eldridge on 2019/06/24.
//  Copyright © 2019 TCT Digital. All rights reserved.
//

import Foundation

public class StripeResponse: NSObject, Decodable {
    
    public var id: String?
    public var card: StripeCard?
    
    enum CodingKeys: String, CodingKey {
        case id
        case card
    }
}


