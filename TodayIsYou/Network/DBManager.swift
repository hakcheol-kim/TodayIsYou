//
//  DBManager.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/10.
//

import UIKit
import CoreData
enum DBName: String {
    case chatmessage = "ChatMessage"
}

class DBManager: NSObject {
    static let ins = DBManager()
    private let viewcontext = AppDelegate.ins.persistentContainer.viewContext
    
    func getAllChatMessage(_ completion:@escaping(_ messages:[ChatMessage]?, _ error:Error?) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: DBName.chatmessage.rawValue)
        do {
            let result = try viewcontext.fetch(request) as? [ChatMessage]
            completion(result, nil)
        } catch let error {
            completion(nil, error)
        }
    }
    func getChatMessage(messageKey:String, _ completion:@escaping(_ messages:[ChatMessage]?, _ error:Error?) -> Void) {
        let predicate = NSPredicate.init(format: "%K = %@", "message_key", messageKey)
        let des = NSSortDescriptor.init(key: "reg_date", ascending: true)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: DBName.chatmessage.rawValue)
        request.predicate = predicate
        request.sortDescriptors = [des]
        viewcontext.refreshAllObjects()
        do {
            let result = try viewcontext.fetch(request) as? [ChatMessage]
            completion(result, nil)
        } catch let error {
            completion(nil, error)
        }
    }
    func getAllUnReadMessageCount(_ completion:@escaping(_ count:Int) ->Void) {
        let isRead = NSNumber.init(booleanLiteral: false)
        let predicate = NSPredicate.init(format: "(%K = %@)", "read_yn", isRead)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: DBName.chatmessage.rawValue)
        request.predicate = predicate
        
        viewcontext.refreshAllObjects()
        do {
            let result = try viewcontext.fetch(request) as? [ChatMessage]
            if let result = result, result.isEmpty == false {
                completion(result.count)
            }
            else {
                completion(0)
            }
        } catch {
            completion(0)
        }
    }
    func getUnReadMessageCount(messageKey:String, _ completion:@escaping(_ count:Int) ->Void) {
        self.getUnReadChatMessage(messageKey: messageKey) { (result, error) in
            if let result = result, result.isEmpty == false {
                completion(result.count)
            }
            else {
                completion(0)
            }
        }
    }
    private func getUnReadChatMessage(messageKey:String, _ completion:@escaping(_ messages:[ChatMessage]?, _ error:Error?) -> Void) {
        let isRead = NSNumber.init(booleanLiteral: false)
        let predicate = NSPredicate.init(format: "(%K = %@) AND (%K = %@)", "message_key", messageKey, "read_yn", isRead)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: DBName.chatmessage.rawValue)
        request.predicate = predicate
        
        viewcontext.refreshAllObjects()
        do {
            let result = try viewcontext.fetch(request) as? [ChatMessage]
            completion(result, nil)
        } catch let error {
            completion(nil, error)
        }
    }
    
    func updateReadMessage(messageKey:String, _ completion:@escaping(_ success:Bool, _ error:Error?) ->Void) {
        self.getUnReadChatMessage(messageKey: messageKey) { (result, error) in
            if let result = result, result.isEmpty == false {
                for item in result {
                    item.read_yn = true
                }
                do {
                    try self.viewcontext.save()
                    completion(true, nil)
                }
                catch let error {
                    completion(false, error)
                }
            }
            else {
                completion(true, nil)
            }
        }
    }
    
    func insertChatMessage(_ param:[String:Any], _ completion:@escaping(_ success:Bool, _ error:Error?) -> Void) {
        guard let message_key = param["message_key"] as? String else {
            return
        }
        let chat = NSEntityDescription.insertNewObject(forEntityName: DBName.chatmessage.rawValue, into: self.viewcontext) as! ChatMessage
        chat.message_key = message_key
        chat.type = (param["type"] as? NSNumber)?.int64Value ?? 0
        chat.from_user_id = param["from_user_id"]  as? String
        chat.to_user_id = param["to_user_id"] as? String
        chat.memo = param["memo"]  as? String
        chat.reg_date = param["reg_date"] as? Date
        chat.file_name = param["file_name"] as? String
        chat.read_yn = param["read_yn"] as! Bool
        chat.to_user_name = param["to_user_name"] as? String
        chat.from_user_name = param["from_user_name"] as? String
        chat.profile_name = param["profile_name"] as? String
        
        do {
            try viewcontext.save()
            completion(true, nil)
        } catch let error {
            completion(false, error)
        }
    }
    
    func deleteChatMessage(messageKey:String, _ completion:@escaping(_ success:Bool, _ error:Error?) ->Void) {
        self.getChatMessage(messageKey: messageKey) { (chats, error) in
            guard let chats = chats, chats.isEmpty == false else {
                completion(true, nil)
                return
            }
            for chat in chats {
                self.viewcontext.delete(chat)
            }
            
            do {
                try self.viewcontext.save()
                completion(true, nil)
            }
            catch let error {
                completion(false, error)
            }
        }
    }
}
