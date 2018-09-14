//
//  PeachResponse.swift
//  HeyJudeSDK
//
//  Created by Byron Tudhope on 2018/09/14.
//

public class PeachResponse: NSObject, Decodable {

    public var id: String?
    public var result: PeachResult?
    public var card: Card?

    enum CodingKeys : String, CodingKey {
        case id
        case result
        case card
    }
}
