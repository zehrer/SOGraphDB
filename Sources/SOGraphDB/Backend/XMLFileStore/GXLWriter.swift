//
//  GXLWriter.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 15.01.18.
//

import Foundation

class GXLWriter {
    
    let store: XMLFileStore
    
    var xml = ""
    
    let documentHeader = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    
    init(store: XMLFileStore) {
        self.store = store
    }
    
    func writeHeader() {
        xml = documentHeader
    }
    
    func write(startElement elementName: String,
               attributes attributeDict: [String : String] = [String : String]()) {
        
        var xmlAttributes = ""
        
        for (attributeName,attributeValue) in attributeDict {
            xmlAttributes += " \(attributeName)=\"\(attributeValue)\""
        }
        
        xml += "<\(elementName)\(xmlAttributes)>\n"
    }
    
    func write(endElement elementName: String) {
        xml += "</\(elementName)>\n"
    }
    
    func write(elementText text: String) {
        xml += text
    }
    
    func writeAttributeValue(_ property: Property ) {
        
        switch property.type {
        case .undefined: break
        case .boolean:
            write(startElement: GLX.Property.bool)
            break
        case .integer:
            write(startElement: GLX.Property.int)
            break
        case .string:
            write(startElement: GLX.Property.string)
            break
        }
        
        write(elementText: property.string())
        
        switch property.type {
        case .undefined: break
        case .boolean:
            write(endElement: GLX.Property.bool)
            break
        case .integer:
            write(endElement: GLX.Property.int)
            break
        case .string:
            write(endElement: GLX.Property.string)
            break
        }
    }
    
    func writeAttributes(_ element: PropertyElement) {
        element.onAllProperties{ (property) in
            
            let keyNodeID = String(property.keyNodeID)
            write(startElement: GLX.Elements.property, attributes: [GLX.Attributes.key: keyNodeID] )
            writeAttributeValue(property)
            write(endElement: GLX.Elements.property)
            
        }
    }
    
    func writeElement(type: String, element: PropertyElement) {
        
        let uid = String(element.uid)
        write(startElement: type, attributes: [GLX.Attributes.id: uid] )
        writeAttributes(element)
        write(endElement: type)
        
    }
    

    func writeXML() -> String {
        writeHeader()
        
        write(startElement: GLX.Elements.glx)
         write(startElement: GLX.Elements.graph, attributes: [GLX.Attributes.id: "1"] )
        
         // write all nodes
         store.onAllNodes { (node) in
            writeElement(type: GLX.Elements.node, element: node)
         }
        
         // write all relationships
        store.onAllRelationships { (rel) in
            writeElement(type: GLX.Elements.relationship, element: rel)
        }
        
         write(endElement: GLX.Elements.graph)
        write(endElement: GLX.Elements.glx)
        
        return xml
    }
    
    func write(file url:URL) throws {
        
        /**
        do {
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */}
        */
    }
}
