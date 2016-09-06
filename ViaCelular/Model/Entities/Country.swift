import Foundation

@objc(Country)
public class Country: _Country {
    
    static func fetchCurrentCountry(handler: (country: Country?, location:Location?, countries: [Country]?, error: NSError?) -> Void) {
        
        //Get the list of countries
        self.list { (countries, error) -> Void in
            
            guard let countries = countries else {
                DLog(error?.localizedDescription)
                handler(country: nil, location:nil, countries: nil, error: error)
                return
            }
            
            //Get the current location
            Location.fetchCurrentLocation({ (location, error) -> Void in
                
                guard let location = location, countryCode = location.countryCode else {
                    DLog(error?.localizedDescription)
                    handler(country: nil, location:nil, countries: countries, error: error)
                    return
                }
                
                //Invoke completion handler by looking up the country by a country code gotten from the location
                handler(country: self.countryByCode(countryCode), location: location, countries: countries, error: error)
                
            })
            
        }
    }
    
    private static func list(handler: ((countries: [Country]?, error: NSError?) -> Void)? = nil) {
        
        if isEnvDev
        {
            // Test
            engine.GET(.Countries, params: nil, mapping: [(.Path("compiledCountries") => .Array(Country.self))]).onSuccess { (results) -> Void in
                
                handler?(countries: results.first as? [Country], error: nil)
                
                }.onFailure { (error) -> Void in
                    
                    DLog(error.localizedDescription)
                    handler?(countries: nil, error: error)
                    
            }
        } else
        {
            // Production
            engine.GET(.Countries, params: nil, mapping: [(.Path("data") => .Array(Country.self))]).onSuccess { (results) -> Void in
            
                handler?(countries: results.first as? [Country], error: nil)
            
                }.onFailure { (error) -> Void in
            
                    DLog(error.localizedDescription)
                    handler?(countries: nil, error: error)
            
            }
        }
        
    }
    
    private static func countryByCode(countryCode: String) -> Country? {
        return Country.MR_findFirstByAttribute("isoCode", withValue: countryCode) as? Country
    }
    
    var codeWithoutCellPhonePrefix: String? {
        get {
            if let code = self.code where code.hasSuffix("9") {
                return String(code.characters.dropLast(1))
            }
            return self.code
        }
    }
    
}
