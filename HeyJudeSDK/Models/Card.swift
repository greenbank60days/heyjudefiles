//
//  Card.swift
//  HeyJudeSDK
//
//  Created by Byron Tudhope on 2018/09/14.
//

public class Card: NSObject, Decodable {

    public var bin: String?
    public var last4Digits: String?
    public var holder: String?
    public var expiryMonth: String?
    public var expiryYear: String?

    enum CodingKeys : String, CodingKey {
        case bin
        case last4Digits
        case holder
        case expiryMonth
        case expiryYear
    }

}
