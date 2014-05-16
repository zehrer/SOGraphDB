#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "SOGraphDB"
  s.version          = "0.1.1"
  s.summary          = "A graph database library."
  s.description      = <<-DESC
                       The idea of SOGraphDB is to implement a persistent layer based on the graph theory.
                       The project is inspired by neo4j and a the related book http://graphdatabases.com.
                       
                       The target is a local fast and lightwight database which solve restrictions of RDB libries:
                       * Schema-less and therefore flexible, data migration any more (low risk)
                       * support native arbitrary sorts
                       * optimized on native COCOA types 
                       * optimized persistent technology (flash)
                       * optimized on mobile platform iOS.
                       
                       This project start at the moment only with a persistent layer cover:
                       * Nodes and relationships as first class members
                       * Provide proerties for both nodes and relationships
                       * Support major native types
                       * Store unique (short) string store 
                       
                       Futher elements may be/are:
                       * Full ACID implementation 
                       * platform independent encoding
                       * RDF interface
                       * RDF in and export
                       * Improve string store (e.g. compression)
                       * iCloud integration 
                       
                       DESC
  s.homepage         = "http://semobj.com/SOGrapheDB"
  s.screenshots      = "http://semobj.com/SOGrapheDB"
  s.license          = 'MIT'
  s.author           = { "Stephan Zehrer" => "stephan@zehrer.net" }
  s.source           = { :git => "https://github.com/zehrer/SOGraphDB.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/#SOGrapheDB'

  s.platform     = :ios, '7.1'
  s.ios.deployment_target = '7.1'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.resources = 'Assets/*.png'

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Classes/**/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'JSONKit', '~> 1.4'
end
