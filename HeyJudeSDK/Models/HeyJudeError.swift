//
//  HeyJudeError.swift
//  HeyJudeSDK
//
//  Created by Byron Tudhope on 2018/07/22.
//

import UIKit

public class HeyJudeError {

    public var httpResponseCode: Int?
    public var apiErrors: [String]?
    public var requestError: Error?
    public var response: URLResponse?
    public var sessionEnded: Bool

    init(httpResponseCode: Int?, apiErrors: [String]?, requestError: Error?, response: URLResponse?) {
        if httpResponseCode != nil {
            self.httpResponseCode = httpResponseCode
        }
        if apiErrors != nil {
            self.apiErrors = apiErrors
        }
        if requestError != nil {
            self.requestError = requestError
        }
        if response != nil {
            self.response = response
        }
        self.sessionEnded = false
    }


//    public var description: String {
//        var description = "\n*******Payment Request*******\n"
//        description += "id: \(self.id!)\n"
//        description += "currency: \(self.currency!)\n"
//        description += "amountTotal: \(self.amountTotal!)\n"
//        description += "status: \(self.status!)\n"
//        description += "details: \(self.details!)\n"
//        description += "invoiceDescription: \(self.invoiceDescription!)\n"
//        return description
//    }
}
