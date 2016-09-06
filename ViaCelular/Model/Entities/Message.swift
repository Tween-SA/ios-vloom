import Foundation

enum MessageStatus: Int
{
    case Creado = 0
    case EnvioPendiente = 1
    case Enviado = 2
    case Recibido = 3
    case Leido = 4
    case Spam = 5
    case Eliminado = 6
}

@objc(Message)
public class Message: _Message {

    var unRead:Bool {
        get {
            return self.status?.integerValue < MessageStatus.Leido.rawValue && self.erase?.intValue != 1
        }
    }
    
    func getDetail(handler: (succeeded: Bool, error: NSError?) -> Void) {

        engine.GET(.CompanyMessageById, params: self.export(fields: ["companyId", "id"]), mapping: [.Root => .ObjectUpdate(self)]).onSuccess { (results) -> Void in
            
            handler(succeeded: true, error: nil)
            
        }.onFailure { (error) -> Void in
            
            handler(succeeded: false, error: error)
            
        }
        
    }

    static func setMessageState(MessageId: String, Status: Int, handler: (succeeded: Bool, error: NSError?) -> Void) {
        Message.setMessageState(MessageId,
                                Latitude: nil,
                                Longitude: nil,
                                Status: Status,
                                handler: handler)
    }
    
    static func setMessageState(MessageId: String, Latitude:Float?, Longitude:Float?, Status: Int, handler: (succeeded: Bool, error: NSError?) -> Void) {
        
        var params:[String:AnyObject] = [:]
        params["id"] = MessageId
        params["status"] = Status
        
        if Latitude != nil && Longitude != nil {
            params["geolocalization"] = ["latitude":Latitude!,"longitude":Longitude!]
        }
        
        engine.PUT(.Message, params: params).onSuccess { (results) -> Void in
            
            handler(succeeded: true, error: nil)
            
            }.onFailure { (error) -> Void in
                handler(succeeded: false, error: error)
                
        }
    }

    static func setMessagesState(Messages: [Message], Status: MessageStatus, handler: (succeeded: Bool, error: NSError?) -> Void) {
        
        
        if Messages.count > 0 {
            var params:[[String:AnyObject]] = []
            
            for msg:Message in Messages {
                if let msgId = msg.msgId {
                    params.append(["id": msgId,"status" : Status.rawValue])
                }
            }
            
            engine.PUT(.Messages, params: params).onSuccess { (results) -> Void in
                
                for msg:Message in Messages {
                    msg.status = Status.rawValue
                }
                
                handler(succeeded: true, error: nil)
                
                }.onFailure { (error) -> Void in
                    handler(succeeded: false, error: error)
                    
            }
        }else{
            handler(succeeded: true, error: nil)
        }
        
    }
    
    static func getMessageById(MesssageId: String) -> Message
    {
        return (MR_findFirstByAttribute("id", withValue: MesssageId) as? Message)!
    }
    
    static func listLocalMessages(companyId:String? = nil) -> [Message]{
        var predicate:NSPredicate?
        if companyId != nil {
            predicate = NSPredicate(format: "companyId == %@ and status < 5 and ( erase == nil or erase != 1)",companyId!)
        }else{
            predicate = NSPredicate(format: "status < 5 and ( erase == nil or erase != 1)")
        }
        
        let mesages =  Message.MR_findAllWithPredicate(predicate!)
        if mesages != nil{
            return mesages as! [Message]
        }else{
            return []
        }
    }

    
}
