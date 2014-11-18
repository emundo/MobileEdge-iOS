/*
 * Copyright (c) 2014 eMundo
 * All Rights Reserved.
 *
 * This file is part of MobileEdge-iOS.
 * MobileEdge-iOS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MobileEdge-iOS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with MobileEdge-iOS.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Created by Raphael Arias on 8/13/14.
 */

#import "MOBTorInterface.h"
#import "MOBCore.h"
#include <CPAProxy/CPAProxy.h>

@class TorController;

@interface MOBTorInterface ()

@property (nonatomic, copy) ConnectSuccessfulBlock onConnect;

@property (nonatomic, copy) ConnectFailureBlock onFailure;

@property (nonatomic, strong) CPAConfiguration *configuration;

@property (nonatomic, strong) CPAProxyManager *cpaProxyManager;

@end

@implementation MOBTorInterface

- (instancetype) initWithSettings: (id<MOBAnonymizerSettings>) aSettings
{
    if (self = [super init])
    {
        self.settings = aSettings;
        
        // Get resource paths for the torrc and geoip files from the main bundle
        NSURL *cpaProxyBundleURL = [[NSBundle mainBundle] URLForResource: @"CPAProxy" withExtension: @"bundle"];
        NSBundle *cpaProxyBundle = [NSBundle bundleWithURL: cpaProxyBundleURL];
        NSString *torrcPath = [cpaProxyBundle pathForResource: @"torrc" ofType: nil];
        NSString *geoipPath = [cpaProxyBundle pathForResource: @"geoip" ofType: nil];

        // Place to store Tor caches (non-temp storage improves performance since
        // directory data does not need to be re-loaded each launch)
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *torDataDir = [documentsDirectory stringByAppendingPathComponent: @"tor"];

        // Initialize a CPAProxyManager
        self.configuration = [CPAConfiguration configurationWithTorrcPath: torrcPath
                                                                geoipPath: geoipPath
                                                     torDataDirectoryPath: torDataDir];
        self.cpaProxyManager = [CPAProxyManager proxyWithConfiguration: self.configuration];
    }
    return self;
}

- (void) handleCPAProxySetupWithSOCKSHost: (NSString *) SOCKSHost SOCKSPort: (NSUInteger) SOCKSPort
{
    // Create a NSURLSessionConfiguration that uses the newly setup SOCKS proxy
    NSDictionary *proxyDict = @{
                                (NSString *) kCFStreamPropertySOCKSProxyHost : SOCKSHost,
                                (NSString *) kCFStreamPropertySOCKSProxyPort : @(SOCKSPort)
                                };
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.connectionProxyDictionary = proxyDict;
    
    // Create a NSURLSession with the configuration
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration: configuration
                                                             delegate: self
                                                        delegateQueue: [NSOperationQueue mainQueue]];
    
    // Send an HTTP GET Request using NSURLSessionDataTask
    NSURL *URL = [NSURL URLWithString: @"https://check.torproject.org"];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL: URL];
    [dataTask resume];
    
    // ...
}

- (void) connectOnFinishExecuteBlock: (ConnectSuccessfulBlock) aOnConnect
                             failure: (ConnectFailureBlock) aOnFailure
{
    self.onConnect = aOnConnect;
    self.onFailure = aOnFailure;
    // TODO: Add connection code here!
    [self.cpaProxyManager setupWithCompletion:^(NSString *socksHost, NSUInteger socksPort, NSError *error) {
        if (error == nil) {
            // ... do something with Tor socks hostname & port ...
            NSLog(@"Connected: host=%@, port=%lu", socksHost, (long) socksPort);
            
            // ... like this -- see below for implementation ...
            [self handleCPAProxySetupWithSOCKSHost: socksHost SOCKSPort: socksPort];
            self.onConnect();
        }
    } progress:^(NSInteger progress, NSString *summaryString) {
        // ... do something to notify user of tor's initialization progress ...
        NSLog(@"%li %@", (long)progress, summaryString);
    }];
    //[self.tor startTor];
}


@end
