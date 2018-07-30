//
//  Data.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/15.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

public class Data: NSObject, Decodable {

    public var user: User?
    public var tasks: [Task]?
    public var paymentMethods: [PaymentMethod]?
    public var payments: [Payment]?
    public var paymentRequest: PaymentRequest?
    public var task: Task?
    public var subscriptionOptions: [SubscriptionOption]?
    public var subscriptionStatus: SubscriptionStatus?
    public var attachment: Attachment?
    public var featuredImage: FeaturedImage?
    public var countries: [Country]?
    public var taskRating: Int?

    enum CodingKeys : String, CodingKey {
        case user
        case tasks
        case paymentMethods = "payment_methods"
        case payments
        case paymentRequest = "payment_request"
        case task
        case subscriptionOptions = "subscription_options"
        case subscriptionStatus = "subscription_status"
        case attachment
        case featuredImage = "featured_image"
        case countries
        case taskRating = "task_rating"
    }

}
