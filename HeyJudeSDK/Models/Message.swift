//
//  Message.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/16.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

public class Message: Decodable, CustomStringConvertible {

    public init () {
        
    }

    public var id: Int?
    public var taskId: Int?
    public var text: String?
    public var fromUser: Bool?
    public var fromUserString: String?
    public var unixTimestamp: String?
    public var type: String?
    public var amount: String?
    public var currency: String?
    public var paymentDescription: String?
    public var supplier: String?
    public var paymentRequestId: Int?
    public var status: String?
    public var latitude: String?
    public var longitude: String?
    public var mapUrl: String?
    public var address: String?
    public var vendors: [Vendor]?
    public var size: Int?
    public var mime: String?
    public var attachmentExtension: String?
    public var attachmentId: Int?


    enum CodingKeys : String, CodingKey {
        case id
        case taskId = "task_id"
        case fromUser = "from_user"
        case fromUserString = "from_user_string"
        case unixTimestamp = "unix_timestamp"
        case type
        case text
        case amount
        case currency
        case paymentDescription = "description"
        case supplier
        case paymentRequestId = "payment_request_id"
        case status
        case latitude
        case longitude
        case mapUrl = "image_url"
        case address
        case vendors
        case size
        case mime
        case attachmentExtension = "extension"
        case attachmentId = "attachment_id"
    }

    public var description: String {
        var description = "\n*******Message*******\n"
        description += "id: \(self.id!)\n"
        if taskId != nil {
            description += "taskId: \(self.taskId!)\n"
        }
        description += "fromUser: \(self.fromUser!)\n"
        description += "fromUserString: \(self.fromUserString!)\n"
        description += "unixTimestamp: \(self.unixTimestamp!)\n"
        description += "type: \(self.type!)\n"
        switch self.type {
        case "text":
            description += "text: \(self.text!)\n"
        case "payment":
            description += "amount: \(self.amount!)\n"
            description += "currency: \(self.currency!)\n"
            description += "paymentDescription: \(self.paymentDescription!)\n"
            description += "supplier: \(self.supplier!)\n"
            description += "paymentRequestId: \(self.paymentRequestId!)\n"
            description += "status: \(self.status!)\n"
        case "map":
            description += "latitude: \(self.latitude!)\n"
            description += "longitude: \(self.longitude!)\n"
            description += "mapUrl: \(self.mapUrl!)\n"
            description += "address: \(self.address!)\n"
        case "vendor":
            for vendor in self.vendors! {
                description += "vendor: \(vendor.description)\n"
            }
        case "image":
            description += "size: \(self.size!)\n"
            description += "mime: \(self.mime!)\n"
            description += "attachmentExtension: \(self.attachmentExtension!)\n"
            description += "attachmentId: \(self.attachmentId!)\n"
        case "audio":
            description += "size: \(self.size!)\n"
            description += "mime: \(self.mime!)\n"
            description += "attachmentExtension: \(self.attachmentExtension!)\n"
            description += "attachmentId: \(self.attachmentId!)\n"
        case "document":
            description += "size: \(self.size!)\n"
            description += "mime: \(self.mime!)\n"
            description += "attachmentExtension: \(self.attachmentExtension!)\n"
            description += "attachmentId: \(self.attachmentId!)\n"
        case "rating":
            description += "text: \(self.text!)\n"
        default:
            break
        }
        return description
    }

}
