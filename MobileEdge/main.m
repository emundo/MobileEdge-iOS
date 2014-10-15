//
//  main.m
//  MOBviewTest
//
//  Created by luc  on 30.07.14.
//  Copyright (c) 2014 BOSS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MOBAppDelegate.h"
#import "../external/Tor/ProxyURLProtocol.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        //[NSURLProtocol registerClass:[ProxyURLProtocol class]];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([MOBAppDelegate class]));
    }
}
