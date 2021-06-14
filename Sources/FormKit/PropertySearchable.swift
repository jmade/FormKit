
import Foundation


protocol PropertySearchable
{
    func allProperties() throws -> [(String,String)]
}

extension PropertySearchable {
    func allProperties() throws -> [(String,String)] {
        
        var result: [(String,String)] = []
        
        let mirror = Mirror(reflecting: self)
        
        // Optional check to make sure we're iterating over a struct or class
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            throw NSError()
        }
         
        for (property,value) in mirror.children {
            if let prop = property {
                result.append((prop,String(describing: value)))
            }
        }
        
        return result
    }
}
