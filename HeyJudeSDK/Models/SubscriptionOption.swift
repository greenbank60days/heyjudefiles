//
//  SubscriptionOption.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/18.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

public class SubscriptionOption: Decodable, CustomStringConvertible {

    public var id: Int?
    public var name: String?
    public var subscriptionOptionDescription: String?
    public var currency: String?
    public var price: String?
    public var amount: Int?
    public var unit: String?
    public var available: Bool?
    public var type: String?
    public var isTrial: Bool?
    public var isPro: Bool?
    public var proHours: String?
    public var duration: String?


    enum CodingKeys : String, CodingKey {
        case id
        case name
        case subscriptionOptionDescription = "description"
        case currency
        case price
        case amount
        case unit
        case available
        case type
        case isTrial = "is_trial"
        case isPro = "is_pro"
        case proHours = "pro_hours"
        case duration
    }

    public var description: String {
        var description = "\n*******Subscription Option*******\n"
        description += "id: \(self.id!)\n"
        description += "name: \(self.name!)\n"
        description += "description: \(self.subscriptionOptionDescription!)\n"
        description += "currency: \(self.currency!)\n"
        description += "price: \(self.price!)\n"
        description += "amount: \(self.amount!)\n"
        description += "unit: \(self.unit!)\n"
        description += "available: \(self.available!)\n"
        description += "type: \(self.type!)\n"
        description += "isTrial: \(self.isTrial!)\n"
        description += "isPro: \(self.isPro!)\n"
        description += "proHours: \(self.proHours!)\n"
        description += "duration: \(self.duration!)\n"
        return description
    }
}
