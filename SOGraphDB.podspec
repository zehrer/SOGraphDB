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
The project is inspired by [Neo4j](http://www.neo4j.org) and a the related book [Graph Databases](http://graphdatabases.com).


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
