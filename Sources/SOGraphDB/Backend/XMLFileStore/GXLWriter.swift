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
    
    let documentHeader = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    
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
        
        xml += "<\(elementName)\(xmlAttributes)>"
    }
    
    func write(endElement elementName: String) {
        xml += "</\(elementName)>"
    }
    
    func write(elementText text: String) {
        xml += text
    }
    
    func writeAttributes(_ element: PropertyElement) {
        element.onAllProperties{ (property) in
            
            let keyNodeID = String(property.keyNodeID)
            write(startElement: GLX.Elements.property, attributes: [GLX.Attributes.key: keyNodeID] )
            write(elementText: property.string())
            write(endElement: GLX.Elements.property)
            
        }
    }
    
    func writeElement(type: String, element: PropertyElement) {
        
        let uid = String(element.uid)
        write(startElement: type, attributes: [GLX.Attributes.key: uid] )
        writeAttributes(element)
        write(endElement: type)
        
    }
    

    
    
    
    func writeXML() {
        writeHeader()
        
        write(startElement: GLX.Elements.glx)
         write(startElement: GLX.Elements.graph, attributes: [GLX.Attributes.key: "01"] )
        
         // write all nodes
         store.onAllNodes { (node) in
            writeElement(type: GLX.Elements.node, element: node)
         }
        
         // write all relationships
        store.onAllRelationships { (rel) in
            writeElement(type: GLX.Elements.property, element: rel)
        }
        
         write(endElement: GLX.Elements.graph)
        write(endElement: GLX.Elements.glx)
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
