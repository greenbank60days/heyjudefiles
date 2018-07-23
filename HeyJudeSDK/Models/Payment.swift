//
//  Payment.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/18.
//  Copyright © 2018 TCT Digital. All rights reserved.
//


import UIKit

public class Payment: Decodable, CustomStringConvertible {

    public var id: Int?
    public var currency: String?
    public var status: String?
    public var amount: String?
    public var card: String?
    public var cardBrand: String?
    public var date: String?
    public var supplier: String?
    public var paymentDescription: String?


    enum CodingKeys : String, CodingKey {
        case id
        case currency
        case status
        case amount
        case card
        case cardBrand = "card_brand"
        case date
        case supplier
        case paymentDescription = "description"
    }

    public var description: String {
        var description = "\n*******Payment*******\n"
        description += "id: \(self.id!)\n"
        description += "currency: \(self.currency!)\n"
        description += "status: \(self.status!)\n"
        description += "amount: \(self.amount!)\n"
        description += "card: \(self.card!)\n"
        description += "cardBrand: \(self.cardBrand!)\n"
        description += "date: \(self.date!)\n"
        description += "supplier: \(self.supplier!)\n"
        description += "paymentDescription: \(self.paymentDescription!)\n"
        return description
    }
}
