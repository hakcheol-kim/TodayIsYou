//
//  ChatMessage+CoreDataProperties.swift
//  
//
//  Created by 김학철 on 2021/04/12.
//
//

import Foundation
import CoreData


extension ChatMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatMessage> {
        return NSFetchRequest<ChatMessage>(entityName: "ChatMessage")
    }

    @NSManaged public var from_user_id: String?
    @NSManaged public var memo: String?
    @NSManaged public var reg_date: Date?
    @NSManaged public var to_user_id: String?
    @NSManaged public var type: Int64
    @NSManaged public var file_name: String?
    @NSManaged public var read_yn: Bool
    @NSManaged public var message_key: String?
    @NSManaged public var to_user_name: String?
    @NSManaged public var from_user_name: String?
    @NSManaged public var profile_name: String?
    @NSManaged public var height: Double

}
