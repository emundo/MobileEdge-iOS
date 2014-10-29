//
//  MOBAxolotlLocalTest.m
//  MobileEdge
//
//  Created by Raphael Arias on 28/10/14.
//  Copyright (c) 2014 eMundo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MOBCore.h"
#import "MOBAxolotl.h"
#import "MOBProtocol.h"


@interface MOBAxolotlLocalTest : XCTestCase

@end

@implementation MOBAxolotlLocalTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void) testKeyExchange
{
    MOBIdentity *alice = [[MOBIdentity alloc] init];
    MOBIdentity *bob = [[MOBIdentity alloc] init];
    MOBAxolotl *axolotl = [[MOBAxolotl alloc] initWithIdentity: alice];
    MOBAxolotl *bxolotl = [[MOBAxolotl alloc] initWithIdentity: bob];
    
    MOBRemoteIdentity *aRemote = [[MOBRemoteIdentity alloc] initWithPublicKey: alice.identityKey];
    MOBRemoteIdentity *bRemote = [[MOBRemoteIdentity alloc] initWithPublicKey: bob.identityKey];
    
    
    KeyExchangeSendBlock alicesSendingBlock = ^(NSDictionary *alicesKeyExchangeMessage, KeyExchangeFinalizeBlock alicesFinalizeBlock) {
        NSData *alicesKeyExchangeMessageData =
            [NSJSONSerialization dataWithJSONObject: alicesKeyExchangeMessage
                                            options: 0
                                              error: nil];
        KeyExchangeSendBlockBob bobsSendingBlock = ^(NSDictionary *bobsKeyExchangeMessage)
        {
            alicesFinalizeBlock ([NSJSONSerialization dataWithJSONObject: bobsKeyExchangeMessage options: 0 error: nil]);
        };
        [bxolotl performKeyExchangeWithAlice: aRemote
                     usingKeyExchangeMessage: alicesKeyExchangeMessageData
              andSendKeyExchangeMessageUsing: bobsSendingBlock];
    };
    
    [axolotl performKeyExchangeWithBob: bRemote andSendKeyExchangeMessageUsing: alicesSendingBlock];
    //NSLog(@"DATA 1: %@\n", [axolotl getSessionKeyMaterialForTestingForRemote: bRemote]);
    //NSLog(@"DATA 2: %@\n", [bxolotl getSessionKeyMaterialForTestingForRemote: aRemote]);
    XCTAssert([[axolotl getSessionKeyMaterialForTestingForRemote: bRemote]
               isEqualToData: [bxolotl getSessionKeyMaterialForTestingForRemote: aRemote]],
              @"DATA 1: %@ \nDATA 2: %@", [axolotl getSessionKeyMaterialForTestingForRemote:bRemote], [bxolotl getSessionKeyMaterialForTestingForRemote:aRemote]);
}

@end
