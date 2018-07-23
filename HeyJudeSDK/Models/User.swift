//
//  User.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/15.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

import UIKit

public class User: Decodable, CustomStringConvertible {

    public var id: Int?
    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public var fullName: String?
    public var mobile: String?
    public var profileImage: String?
    public var referralCode: String?
    public var paymentProvider: String?
    public var country: String?
    public var pushNotifications: Bool?
    public var greenerChoices: Bool?
    public var roadblocks: [Roadblock]?

    public var description: String {
        var description = "\n*******USER*******\n"
        description += "id: \(self.id!)\n"
        description += "email: \(self.email!)\n"
        description += "firstName: \(self.firstName!)\n"
        description += "lastName: \(self.lastName!)\n"
        description += "fullName: \(self.fullName!)\n"
        description += "mobile: \(self.mobile!)\n"
        description += "profileImage: \(self.profileImage!)\n"
        description += "referralCode: \(self.referralCode!)\n"
        description += "paymentProvider: \(self.paymentProvider!)\n"
        description += "country: \(self.country!)\n"
        description += "pushNotifications: \(self.pushNotifications!)\n"
        description += "greenerChoices: \(self.greenerChoices!)\n"
        description += "roadblocks:\n"

        for roadblock in roadblocks! {
            description += "\(roadblock.description)\n"
        }
        return description
    }

    enum CodingKeys : String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case fullName = "full_name"
        case mobile
        case profileImage = "profile_image"
        case referralCode = "referral_code"
        case paymentProvider = "payment_provider"
        case country
        case pushNotifications = "push_notifications"
        case greenerChoices = "greener_choices"
        case roadblocks
    }

}

