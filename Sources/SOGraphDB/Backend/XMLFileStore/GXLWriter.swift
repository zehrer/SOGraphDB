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
    
    func writeLineFeed() {
        xml += "\n"
    }
    
    func write(startElement elementName: String,
               attributes attributeDict: [String : String] = [String : String]()) {
        
        var xmlAttributes = ""
        
        for (attributeName,attributeValue) in attributeDict {
            xmlAttributes += " \(attributeName)=\"\(attributeValue)\""
        }
        
        xml += "<\(elementName)\(xmlAttributes)>"
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
        case .uid:
            write(startElement: GLX.Property.uid)
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
        case .uid:
            write(endElement: GLX.Property.uid)
        }
    }
    
    func writeAttributes(_ element: Node) {
        element.onAllProperties{ (property) in
            
            let keyNodeID = String(property.keyNodeID)
            write(startElement: GLX.Elements.property, attributes: [GLX.Attributes.key: keyNodeID])
            writeLineFeed()
            writeAttributeValue(property)
            write(endElement: GLX.Elements.property)
            
        }
    }
    
    func writeElement(type: String, element: Node) {
        
        let uid = String(element.uid)
        write(startElement: type, attributes: [GLX.Attributes.id: uid])
        writeLineFeed()
        writeAttributes(element)
        write(endElement: type)
        
    }
    

    func writeXML() -> String {
        writeHeader()
        
        write(startElement: GLX.Elements.glx)
        writeLineFeed()
        
         write(startElement: GLX.Elements.graph, attributes: [GLX.Attributes.id: "0"] )
         writeLineFeed()
        
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
        let text = self.writeXML()
        try text.write(to: url, atomically: false, encoding: .utf8)
    }
}
