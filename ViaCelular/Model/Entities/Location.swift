import Foundation

@objc(Location)
public class Location: _Location {
    
    static var current: Location? {
        get {
            return Location.MR_findFirst() as? Location
        }
    }
    
    static func fetchCurrentLocation(handler: ((location: Location?, error: NSError?) -> Void)? = nil) {
        
        ipEngine.GET(.Location, params: nil, mapping: [.Root => .Object(Location.self)]).onSuccess { (results) -> Void in
            
            handler?(location: results.first as? Location, error: nil)
            
        }.onFailure { (error) -> Void in
            
            handler?(location: nil, error: error)
            
        }
        
    }

}
