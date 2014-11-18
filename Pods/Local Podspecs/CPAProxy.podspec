Pod::Spec.new do |s|
  s.name            = "CPAProxy"
  s.version         = "1.0.0"
  s.summary         = "CPAProxy is a thin Objective-C wrapper around Tor."
  s.author          = "Claudiu-Vlad Ursache <claudiu.vlad.ursache@gmail.com>"

  s.homepage        = "https://github.com/ursachec/CPAProxy"
  s.license         = { :type => 'MIT', :file => 'LICENSE.md' }
  s.source          = { :git => "https://github.com/chrisballinger/CPAProxy.git", :branch => "podspec"}
  s.prepare_command = <<-CMD
    bash ./scripts/build-all.sh
  CMD

  s.dependency 'CocoaAsyncSocket', '~> 7.3'

  s.platform     = :ios, "7.0"
  s.source_files = "CPAProxy/*.{h,m}", "CPAProxyDependencies/tor_cpaproxy.h"
  s.vendored_libraries  = "CPAProxyDependencies/*.a"
  s.resource_bundles = {"CPAProxy" => ["CPAProxyDependencies/geoip", "CPAProxyDependencies/geoip6", "CPAProxyDependencies/torrc"]}
  s.library     = 'crypto', 'curve25519_donna', 'event_core', 'event_extra', 'event_openssl',
                  'event_pthreads', 'event', 'or-crypto', 'or-event', 'or', 'ssl', 'tor', 'z'
  s.requires_arc = true
end