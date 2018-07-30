//
//  ResponseData.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/16.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

public class ResponseData: Decodable {

    public var data: Data?

    enum CodingKeys : String, CodingKey {
        case data
    }

}
