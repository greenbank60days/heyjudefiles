//
//  ResponseData.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/16.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

import UIKit

public class ResponseData: NSObject, Decodable {

    public var data: Data?

    enum CodingKeys : String, CodingKey {
        case data
    }

}
