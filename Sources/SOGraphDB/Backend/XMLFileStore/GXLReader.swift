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
    
    let glxKey = "glx"
    let graphKey = "graph"
    let nodeKey = "node"
    let relationshipKey = "edge"
    let propertyKey = "attr"
    
    let idKey = "id"
    let relStartKey = "from"
    let relEndKey = "to"
    
    let propertyKeyNodeKey = "key"
    let propertyStringKey = "string"
    let propertyIntKey = "int"

    // TODO
    //let osLog = OSLog(subsystem: "net.zehrer.graphdb.plist", category: "testing")
    //os_log("TEXT", log: osLog, type: .debug)
    
    // MARK: -
    
    let store: XMLFileStore
    
    //var currentNode: Node?
    var currentElement : PropertyGraphElement?
    var currentProperty : Property?
    
    //var currentRelationship: Relationship?
    //var currentValue = String()

    // MARK: -
    
    init(store: XMLFileStore) {
        self.store = store

        super.init()
    }
    
    func parse(url: URL) throws {

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
        if let keyNodeID = extractKey(attributes: attributes, key: propertyKeyNodeKey) {
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
    
    private func addNode(attributes: [String : String]) {

        let node = Node()
        
        if let id = extractKey(attributes: attributes,key: idKey) {
            node.uid = id
        } else {
            NSLog("Error: No ID found")
            // TOOD: error
        }

        store.register(node)
        currentElement = node
    }
    
    private func addRelationship(attributes: [String : String]) {
        
        let startID = extractKey(attributes: attributes, key: relStartKey)
        let startNode = store.findNodeBy(uid: startID)
        
        let endID = extractKey(attributes: attributes, key: relEndKey)
        let endNode = store.findNodeBy(uid: endID)
        
        if (startNode != nil) && (endNode != nil) {
            let relationship = Relationship(startNode: startNode!, endNode: endNode!)
            
            extractKey(attributes: attributes,key: idKey) {
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
        switch elementName {
        case glxKey: break
        case graphKey: break
        case nodeKey:
            addNode(attributes: attributeDict)
            break
        case relationshipKey:
            addRelationship(attributes: attributeDict)
            break
        case propertyKey:
            addProperty(attributes: attributeDict)
            break
        case propertyIntKey:
            break
        case propertyStringKey:
            break
        default:
            return
        }
        
        /**
        currentValue = String()
        currentElement = currentParent?.addChild(name: elementName, attributes: attributeDict)
        currentParent = currentElement
        */
    }
    
    public func parser(_ parser: XMLParser,
                       didEndElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qName: String?) {
        
        switch elementName {
        //case glxKey: break
        //case graphKey: break
        case nodeKey:
            currentElement = nil
            break
        case relationshipKey:
            currentElement = nil
            break
        case propertyKey:
            currentProperty = nil
        default:
            return
        }
        
    }
    /**
 

 
 
 optional public func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?)
 
 
 optional public func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?)
 
 
 optional public func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?)
 
 
 optional public func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String)
 
 

 optional public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
 
 

 
 
 optional public func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String)
 
 
 optional public func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String)
 
 
 optional public func parser(_ parser: XMLParser, foundCharacters string: String)
 
 
 optional public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String)
 
 
 optional public func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?)
 
 
 optional public func parser(_ parser: XMLParser, foundComment comment: String)
 
 
 optional public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data)
 
 
 optional public func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data?
 
 
 optional public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
 
 
 optional public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error)
 
 */
    

}
