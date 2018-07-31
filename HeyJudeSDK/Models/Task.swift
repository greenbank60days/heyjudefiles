//
//  Task.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/16.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

public class Task: Decodable, CustomStringConvertible {

    public var id: Int?
    public var title: String?
    public var createdAt: String?
    public var status: String?
    public var open: Bool?
    public var messages: [Message]?


    enum CodingKeys : String, CodingKey {
        case id
        case title
        case createdAt = "created_at"
        case status
        case open
        case messages
    }

    public var description: String {
        var description = "\n*******Task*******\n"
        description += "id: \(self.id!)\n"
        description += "title: \(self.title!)\n"
        description += "createdAt: \(self.createdAt!)\n"
        description += "status: \(self.status!)\n"
        description += "open: \(self.open!)\n"
//        if self.messages != nil {
//            description += "messages: \n"
//            for message in self.messages! {
//                description += "\(message.description)\n"
//            }
//        }
        return description
    }
}
