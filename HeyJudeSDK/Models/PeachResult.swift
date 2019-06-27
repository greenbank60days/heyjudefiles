//
//  PeachResult.swift
//  HeyJudeSDK
//
//  Created by Byron Tudhope on 2018/09/14.
//

public class PeachResult: NSObject, Decodable {

    public var code: String?
    public var message: String?

    enum CodingKeys : String, CodingKey {
        case code
        case message = "description"
    }
}
