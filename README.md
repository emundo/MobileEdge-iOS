#MobileEdge-iOS Framework
This is the MobileEdge-iOS framework. MobileEdge-iOS is the iOS version
of the client-side Framework for the MobileEdge system. 
MobileEdge provides an easy way to include both encryption between
multiple clients and services, as well as anonymity, by routing
connections through Tor.
The MobileEdge framework is still under development and
should __not__ (yet) be used in productive environments. However,
we encourage you to contribute ideas and code if you feel like it!
We are also still working on the server-side counterpart, as well as
an Android version of this framework.

##Architecture
The MobileEdge architecture consists of two seperate parts:

1. client-side frameworks that encrypt data for remote identities 
and decrypt received messages, as well as allowing the routing
of traffic through an anonymizing network (currently only Tor);
2. a server-side frameworks that allow encryption/decryption
of messages, as well as prekey storage. 

While the server functions as a proxy between actual backend and
the network, the client frameworks are actually integrated into the
app and used by app developers.

Key exchange and ratcheting is done using the 
[Axolotl protocol](https://github.com/trevp/axolotl/wiki). Unfortunately,
we started (and almost finished) developing our own implementation of Axolotl before 
WhisperSystems released their [AxolotlKit](https://github.com/WhisperSystems/AxolotlKit).
Future versions might replace our own implementation with AxolotlKit,
if appropriate. For now, we continue using our own implementation
with header encryption and NaCl crypto secretbox as encryption primitive
(via [SodiumObjC] (https://github.com/Tabbedout/SodiumObjc)). 

For anonymization we use [CPAProxy] (https://github.com/ursachec/CPAProxy).

##Usage
We provide a AFNetworking-style API to make developers feel at home.
You should be able to use a MOBHTTPRequestOperationManager much 
in the same way you use an AFHTTPRequestOperationManager, after
some initial configuration.

%TODO: Sample code here.

##Dependencies
All dependencies should be installable via CocoaPods, alongside the
framework. See the _Installation_ instructions below for details.

##Installation
MobileEdge-iOS is installable via CocoaPods, although we have not
yet submitted the podspec. In your podfile you need the following
lines to use MobileEdge in your iOS project.

```ruby
pod "SodiumObjc",          :git => "https://github.com/r-arias/SodiumObjc.git"
pod "CPAProxy",            :git => "https://github.com/ursachec/CPAProxy.git"
pod "MobileEdge",          "~> 0.0", :git => "https://github.com/emundo/MobileEdge-iOS.git"  
```

##Known issues
The connection to the Tor network on first startup is very slow.
This seems to be a known issue with CPAProxy and should hopefully
be fixed in the near future.

##Troubleshooting
Please don't hesitate to open an issue here on github, if you have any
trouble or questions. We have tested the functionality on a small
example project, but at this point we cannot guarantee anything.

