//
//  PaymentMethod.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/17.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

public class PaymentMethod: Decodable, CustomStringConvertible {

    public var id: Int?
    public var lastFourDigits: String?
    public var expiryMonth: String?
    public var expiryYear: String?
    public var brand: String?
    public var isDefault: Bool?
    public var cardNickname: String?
    public var cardHolder: String?


    enum CodingKeys : String, CodingKey {
        case id
        case lastFourDigits = "last_four_digits"
        case expiryMonth = "expiry_month"
        case expiryYear = "expiry_year"
        case brand
        case isDefault = "default"
        case cardNickname = "card_nickname"
        case cardHolder = "card_holder"
    }

    public var description: String {
        var description = "\n*******Payment Method*******\n"
        description += "id: \(self.id!)\n"
        description += "last_four_digits: \(self.lastFourDigits!)\n"
        description += "expiry_month: \(self.expiryMonth!)\n"
        description += "expiry_year: \(self.expiryYear!)\n"
        description += "brand: \(self.brand!)\n"
        description += "default: \(self.isDefault!)\n"
        description += "card_nickname: \(self.cardNickname!)\n"
        description += "card_holder: \(self.cardHolder!)\n"
        return description
    }
}
