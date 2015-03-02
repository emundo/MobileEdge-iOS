Pod::Spec.new do |s|

  s.name         = "MobileEdge"
  s.version      = "0.1.1"
  s.summary      = "The iOS version of the client-side MobileEdge framework."

  s.description  = <<-DESC
                    This is the MobileEdge-iOS pod. MobileEdge-iOS is the iOS version
                    of the client-side Framework for the MobileEdge system. 
                    MobileEdge provides an easy way to include both encryption between
                    multiple clients and services, as well as anonymity, by routing
                    connections through Tor.
                   DESC

  s.homepage     = "http://mobileedgesec.com"

  s.license      = "LGPL v3 or newer"

  s.author             = { "Raphael Arias" => "raphael.arias@e-mundo.de" }
  s.social_media_url   = "http://twitter.com/MobileEdgeSec"
  s.platform     = :ios, "8.1"

  s.source       = { :git => "https://github.com/emundo/MobileEdge-iOS.git", 
                     :tag => "v0.1.1" }
  s.source_files  = "MobileEdge-iOS/**/*.{h,m}"

  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(PODS_ROOT)/SodiumObjC/lib/ios/include/" }
  s.dependency "AFNetworking",         "~> 2.0"
  s.dependency "AFNetworkActivityLogger", "~> 2.0"
  s.dependency "CocoaLumberjack",      "2.0.0-rc2"
  s.dependency "FXKeychain",           "~> 1.5.1"
  s.dependency "HKDFKit",              "~> 0.0.3"
  s.dependency "SodiumObjc" # ,           :git => "https://github.com/r-arias/SodiumObjc.git"
  s.dependency "CPAProxy" #,              :git => 'https://github.com/ursachec/CPAProxy.git' 

end
