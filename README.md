# SOGraphDB

## General

The idea of SOGraphDB is to implement a persistent layer based on the graph theory.
The project is inspired by [Neo4j](http://www.neo4j.org) and a the related book [Graph Databases](http://graphdatabases.com).

The **interface are not stable yet** and the **migration to Swift** started because it seems this language provide essential features to write high quality code.

The target is a local fast and lightweight "database" which solve restrictions of RDB databases:
* Schema-less and therefore flexible -> no data migration any more (reduce risk and [waste](http://en.wikipedia.org/wiki/Lean_manufacturing#Types_of_waste))
* support native arbitrary sorts
* optimized on native COCOA types
* optimized persistent technology (flash)
* optimized on mobile platform iOS.

This project start at the moment only with a persistent layer cover:
* Nodes and relationships as first class members
* Provide properties for both nodes and relationships
* Support major native types
* Provide a store for unique (short) strings

Further elements are in the backlog:
* CloudKit integration (prio 1)
* Improve string store (e.g. compression) (prio 1)
* Full ACID implementation (prio 2)
* RDF layer (prio 3)
* platform independent encoding (prio 3)


## CocoaPods

As you see at the moment this [CocoaPod](http://cocoapods.org) is not added to the CocoPods Specs.

[![Version](http://cocoapod-badges.herokuapp.com/v/SOGraphDB/badge.png)](http://cocoadocs.org/docsets/SOGraphDB)
[![Platform](http://cocoapod-badges.herokuapp.com/p/SOGraphDB/badge.png)](http://cocoadocs.org/docsets/SOGraphDB)

## Requirements
The project is under development and only support (more or less) the latest version of MacOS 1.9.2 and iOS 7.1.

 The design at the moment is to have as less as possible external (not Apple) dependencies and use as much as possible Mac frameworks/libraries.

## Installation

SOGraphDB is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod 'SOGraphDB', :git => 'https://github.com/zehrer/SOGraphDB.git'


## Author

Stephan Zehrer, SOGraphDB@mycontact.org

## License

SOGraphDB is available under the MIT license. See the LICENSE file for more info.
