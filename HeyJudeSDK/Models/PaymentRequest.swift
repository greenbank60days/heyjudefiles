//
//  PaymentRequest.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/18.
//  Copyright © 2018 TCT Digital. All rights reserved.
//
import UIKit

public class PaymentRequest: Decodable, CustomStringConvertible {

    public var id: Int?
    public var currency: String?
    public var amountTotal: String?
    public var status: String?
    public var details: String?
    public var invoiceDescription: String?


    enum CodingKeys : String, CodingKey {
        case id
        case currency
        case amountTotal = "amount_total"
        case status
        case details
        case invoiceDescription = "invoice_description"
    }

    public var description: String {
        var description = "\n*******Payment Request*******\n"
        description += "id: \(self.id!)\n"
        description += "currency: \(self.currency!)\n"
        description += "amountTotal: \(self.amountTotal!)\n"
        description += "status: \(self.status!)\n"
        description += "details: \(self.details!)\n"
        description += "invoiceDescription: \(self.invoiceDescription!)\n"
        return description
    }
}
