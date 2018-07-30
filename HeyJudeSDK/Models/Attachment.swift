//
//  Attachment.swift
//  Hey Jude SDK
//
//  Created by Byron Tudhope on 2018/07/19.
//  Copyright © 2018 TCT Digital. All rights reserved.
//

public class Attachment: Decodable, CustomStringConvertible {

    public var id: Int?
    public var fileExtension: String?
    public var mime: String?
    public var size: Int?
    public var name: String?


    enum CodingKeys : String, CodingKey {
        case id
        case fileExtension = "extension"
        case mime
        case size
        case name
    }

    public var description: String {
        var description = "\n*******Attachment*******\n"
        description += "id: \(self.id!)\n"
        description += "fileExtension: \(self.fileExtension!)\n"
        description += "mime: \(self.mime!)\n"
        description += "size: \(self.size!)\n"
        description += "name: \(self.name!)\n"
        return description
    }
}
