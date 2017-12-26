# SOGraphDB

## General

The idea of SOGraphDB is to implement a persistent layer based on the graph theory.
The project is inspired by [Neo4j](http://www.neo4j.org) and a the related book [Graph Databases](http://graphdatabases.com).

The **interface are not stable yet** and the **migration to Swift** started because it seems this language provide essential features to write high quality code.

The target is a local fast and lightweight "database" which solve restrictions of RDB databases:
* follow the [open world assumption](https://en.wikipedia.org/wiki/Open-world_assumption)
* frontend:
    - optional simple flexible type systems
* backend:
    - schema-less basic structure
* support native arbitrary sorts

This project start at the moment only with a persistent layer cover:
* Nodes and relationships as first class members
* Provide properties for both nodes and relationships
* separation between graphe model and backend storage layer


Further elements are in the backlog:
* simple in memory data and XML backend storage layer (prio1)
* type system (prio2)
* compression for some backends (prio 3)
* RDF layer (prio 4)
* platform independent encoding for binary backend (prio 4)
* CloudKit support (prio 4)
* string managment (e.g. string store) (prio 4)
* Full ACID implementation (prio 5)


## Type systems
*  The idea is to use on the front  end a type system which fulfull later on to implement a "RDF store"
  In this concept the RDF triple is repersented as following:
    * the subject, -> Node
    * the predicate, -> Relationship
    * the object, -> Node
According my current understanding it is suffient to have a single property with the "name" type for a relationship (to represent the predicate)
Subject and Objects may are instances of different types which increase the complexity.

The first implementation will represent the (instance) type for nodes as well as a single property (1:1) instead manage it by the relationships, but this is further to define.

## OLD
* Provide a store for unique (short) strings
* Support major native types
* Schema-less and therefore flexible -> no data migration any more (reduce risk and [waste](http://en.wikipedia.org/wiki/Lean_manufacturing#Types_of_waste))
* optimized on native Swift
* optimized persistent technology (flash)
* optimized on mobile platform iOS.


## CocoaPods

As you see at the moment this [CocoaPod](http://cocoapods.org) is not added to the CocoPods Specs.

[![Version](http://cocoapod-badges.herokuapp.com/v/SOGraphDB/badge.png)](http://cocoadocs.org/docsets/SOGraphDB)
[![Platform](http://cocoapod-badges.herokuapp.com/p/SOGraphDB/badge.png)](http://cocoadocs.org/docsets/SOGraphDB)

## Requirements
The project is under development and only support (more or less) the latest version of MacOS 10.10 and iOS 8.3

 The design at the moment is to have as less as possible external (not Apple) dependencies and use as much as possible Mac frameworks/libraries.

## Installation

SOGraphDB is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod 'SOGraphDB', :git => 'https://github.com/zehrer/SOGraphDB.git'


## Author

Stephan Zehrer, SOGraphDB@mycontact.org

## License

SOGraphDB is available under the MIT license. See the LICENSE file for more info.
