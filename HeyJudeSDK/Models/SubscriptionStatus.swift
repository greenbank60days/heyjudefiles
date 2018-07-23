//
//  SubscriptionStatus.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/18.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

import UIKit

public class SubscriptionStatus: Decodable, CustomStringConvertible {


    public var valid: Bool?
    public var autoRenew: Bool?
    public var renewalDate: String?
    public var expiryText: String?
    public var currentSubscriptionOption: Int?
    public var chosenSubscriptionOption: Int?


    enum CodingKeys : String, CodingKey {
        case valid
        case autoRenew = "auto_renew"
        case renewalDate = "renewal_date"
        case expiryText = "expiry_text"
        case currentSubscriptionOption = "current_subscription_option"
        case chosenSubscriptionOption = "chosen_subscription_option"
    }

    public var description: String {
        var description = "\n*******Subscription Status*******\n"
        description += "valid: \(self.valid!)\n"
        description += "autoRenew: \(self.autoRenew!)\n"
        description += "renewalDate: \(self.renewalDate!)\n"
        description += "expiryText: \(self.expiryText!)\n"
        description += "currentSubscriptionOption: \(self.currentSubscriptionOption!)\n"
        description += "chosenSubscriptionOption: \(self.chosenSubscriptionOption!)\n"
        return description
    }
}
