//
//  GXLReader.swift
//  SOGraphDB
//
//  Created by Stephan Zehrer on 04.01.18.
//

import Foundation

public enum GXLReaderError: Error {
    
    case parserInitFailed

    /// GXLParser throw this error if parsing was not successful.
    case parsingFailed
}


/// Wrapper around `Foundation.XMLParser`.
// This class read the graph xml language GXL (partial), further information:
// http://www.gupro.de/GXL/index.html
// Feature:
// - no hypergraph support
// - 
// The following features are supported for the moment:
// - <graph> : todo
// - <node> : read as node
// - <edge> : read as relationships
// - <attr> : read as property

class GXLReader: NSObject, XMLParserDelegate {

    // TODO
    //let osLog = OSLog(subsystem: "net.zehrer.graphdb.plist", category: "testing")
    //os_log("TEXT", log: osLog, type: .debug)
    
    // MARK: -
    
    let store: XMLFileStore
    
    var currentGraph : Graph?
    var currentElement : PropertyElement?
    var currentProperty : Property?
    var currentValue : String = ""
    
    //var currentRelationship: Relationship?
    //var currentValue = String()

    // MARK: -
    
    init(store: XMLFileStore) {
        self.store = store

        super.init()
    }
    
    func read(url: URL) throws {

        if let parser = XMLParser(contentsOf:url) {
            
            // parser setup
            parser.delegate = self
            
            parser.shouldProcessNamespaces = false
            parser.shouldReportNamespacePrefixes = false
            
            // default is NSXMLParserResolveExternalEntitiesNever
            //parser.externalEntityResolvingPolicy = NSXMLParserResolveExternalEntitiesNever
            
            let success = parser.parse()
            
            if !success {
                guard let error = parser.parserError
                    else {
                        NSLog(url.absoluteString)
                        
                        let line = parser.lineNumber
                        let col = parser.columnNumber
                        
                        NSLog("Line: \(line); Column: \(col)")
                        throw GXLReaderError.parsingFailed
                    }
                throw error
            }
            
        } else {
            throw GXLReaderError.parserInitFailed
        }
    }
    
    // MARK: - Process Data
    
    private func extractKey(attributes: [String : String], key: String) -> Int? {
        
        if let valueString = attributes[key] {
            if let intValue = Int(valueString) {
                return intValue
            }
        }
        
        return nil
    }
    
    private func extractKeyNode(attributes: [String : String]) -> Node? {
        if let keyNodeID = extractKey(attributes: attributes, key: GLX.Attributes.key) {
            if let keyNode = store.findNodeBy(uid: keyNodeID) {
                return keyNode
            }
        }
        
        return nil
    }
    
    private func extractKey(attributes: [String : String], key: String, _ closure: (Int) -> Void) {
        let value = extractKey(attributes:attributes, key: key)
        if value != nil {
            closure(value!)
        }
    }
    
    private func addGraph(attributes: [String : String]) {
        
        var graph : Graph!
        
        if let id = extractKey(attributes: attributes,key: GLX.Attributes.id) {
            graph = Graph(uid: id)
        } else {
            graph = Graph()
        }
        
        store.register(graph)
        currentGraph = graph
    
    }
    
    private func addNode(attributes: [String : String]) {

        var node : Node!
        
        if let id = extractKey(attributes: attributes,key: GLX.Attributes.id) {
            node = Node(uid:id)
        } else {
            node = Node()
        }

        store.register(node)
        
        if let graph = currentGraph {
            graph.add(node)
        }
        
        currentElement = node
    }
    
    private func addRelationship(attributes: [String : String]) {
        
        let startID = extractKey(attributes: attributes, key: GLX.Attributes.relStart)
        let startNode = store.findNodeBy(uid: startID)
        
        let endID = extractKey(attributes: attributes, key: GLX.Attributes.relEnd)
        let endNode = store.findNodeBy(uid: endID)
        
        if (startNode != nil) && (endNode != nil) {
            let relationship = Relationship(startNode: startNode!, endNode: endNode!)
            
            extractKey(attributes: attributes,key: GLX.Attributes.key) {
                relationship.uid  = $0
            }
            
            store.register(relationship)
            currentElement = relationship
        }
    }
    
    private func addProperty(attributes: [String : String]) {
        if let currentElement = currentElement {
            if let keyNode = extractKeyNode(attributes: attributes) {
                let property = currentElement[keyNode]
                self.currentProperty = property
            }
        }
    }
    
    // MARK: - XMLParserDelegate
    
    func parserDidStartDocument(_ parser: XMLParser) {
        NSLog("parserDidStartDocument called")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        NSLog("parserDidEndDocument called")
    }
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String])
    {
        currentValue = ""
        
        switch elementName {
        case GLX.Elements.graph:
            addGraph(attributes: attributeDict)
            break
        case GLX.Elements.node:
            addNode(attributes: attributeDict)
            break
        case GLX.Elements.relationship:
            addRelationship(attributes: attributeDict)
            break
        case GLX.Elements.property:
            addProperty(attributes: attributeDict)
            break
        default:
            return
        }
        
        /**

        currentElement = currentParent?.addChild(name: elementName, attributes: attributeDict)
        currentParent = currentElement
        */
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.currentValue +=  string
    }
    
    public func parser(_ parser: XMLParser,
                       didEndElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qName: String?) {
        
        switch elementName {
        case GLX.Elements.graph:
            currentGraph = nil
            break
        case GLX.Elements.node,
             GLX.Elements.relationship,
             GLX.Elements.property:
            currentElement = nil
            break
        case GLX.Property.int:
            if var property = currentProperty {
                property.intValue = Int(currentValue)
            }
            break
        case GLX.Property.string:
            if var property = currentProperty {
                property.stringValue = currentValue
            }
            break
        default:
            return
        }
        
        currentValue = ""
        
    }
    
    
    public func parser(_ parser: XMLParser,
                       didStartMappingPrefix prefix: String,
                       toURI namespaceURI: String) {
        NSLog("mapping prefix start found: \(prefix) ")
        
    }
    
    
    
 /**
 
 <!NOTATION name SYSTEM "URI">
 optional public func parser(_ parser: XMLParser,
     foundNotationDeclarationWithName name: String,
     publicID: String?,
     systemID: String?)
 
     
 <!ENTITY js "Jo Smith">
 optional public func parser(_ parser: XMLParser,
     foundUnparsedEntityDeclarationWithName name: String,
     publicID: String?,
     systemID: String?,
     notationName: String?)
 
 
 <xs:attribute name="lang" type="xs:string"/>
 optional public func parser(_ parser: XMLParser,
     foundAttributeDeclarationWithName
     attributeName: String,
     forElement elementName: String,
     type: String?,
     defaultValue: String?)
 
 <xsd:element name="element-name" type="xsd:string"/>
 optional public func parser(_ parser: XMLParser,
     foundElementDeclarationWithName elementName: String,
     model: String)

 
 optional public func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String)
 
 
 
 
 
 optional public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String)
 
 
 optional public func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?)
 
 optional public func parser(_ parser: XMLParser, foundComment comment: String)
 
 optional public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data)
 
 optional public func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data?
 
 
 optional public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
 
 
 optional public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error)
 
 */
    

}
