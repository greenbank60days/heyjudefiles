//
//  HeyJudeError.swift
//  HeyJudeSDK
//
//  Created by Byron Tudhope on 2018/07/22.
//

public class HeyJudeError {

    public var httpResponseCode: Int?
    public var apiErrors: [String]?
    public var requestError: Error?
    public var response: URLResponse?
    public var sessionEnded: Bool

    public init(httpResponseCode: Int?, apiErrors: [String]?, requestError: Error?, response: URLResponse?) {
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
}
