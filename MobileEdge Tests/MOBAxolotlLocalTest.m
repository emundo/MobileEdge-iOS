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

@property MOBIdentity *alice;
@property MOBIdentity *bob;
@property MOBAxolotl *axolotl;
@property MOBAxolotl *bxolotl;
@property MOBRemoteIdentity *aRemote;
@property MOBRemoteIdentity *bRemote;

@end

@implementation MOBAxolotlLocalTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.alice = [[MOBIdentity alloc] init];
    self.bob   = [[MOBIdentity alloc] init];
    self.axolotl = [[MOBAxolotl alloc] initWithIdentity: self.alice];
    self.bxolotl = [[MOBAxolotl alloc] initWithIdentity: self.bob];
    
    self.aRemote = [[MOBRemoteIdentity alloc] initWithPublicKey: self.alice.identityKey];
    self.bRemote = [[MOBRemoteIdentity alloc] initWithPublicKey: self.bob.identityKey];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) exchangeKeys
{
    KeyExchangeSendBlock alicesSendingBlock = ^(NSDictionary *alicesKeyExchangeMessage, KeyExchangeFinalizeBlock alicesFinalizeBlock) {
        NSData *alicesKeyExchangeMessageData =
            [NSJSONSerialization dataWithJSONObject: alicesKeyExchangeMessage
                                            options: 0
                                              error: nil];
        KeyExchangeSendBlockBob bobsSendingBlock = ^(NSDictionary *bobsKeyExchangeMessage)
        {
            alicesFinalizeBlock ([NSJSONSerialization dataWithJSONObject: bobsKeyExchangeMessage options: 0 error: nil]);
        };
        [self.bxolotl performKeyExchangeWithAlice: self.aRemote
                     usingKeyExchangeMessage: alicesKeyExchangeMessageData
              andSendKeyExchangeMessageUsing: bobsSendingBlock];
    };
    
    [self.axolotl performKeyExchangeWithBob: self.bRemote andSendKeyExchangeMessageUsing: alicesSendingBlock];
}

- (void) testKeyExchange
{
    [self exchangeKeys];
    
    //NSLog(@"DATA 1: %@\n", [axolotl getSessionKeyMaterialForTestingForRemote: bRemote]);
    //NSLog(@"DATA 2: %@\n", [bxolotl getSessionKeyMaterialForTestingForRemote: aRemote]);
    XCTAssert([[self.axolotl getSessionKeyMaterialForTestingForRemote: self.bRemote]
               isEqualToData: [self.bxolotl getSessionKeyMaterialForTestingForRemote: self.aRemote]],
              @"DATA 1: %@ \nDATA 2: %@", [self.axolotl getSessionKeyMaterialForTestingForRemote: self.bRemote], [self.bxolotl getSessionKeyMaterialForTestingForRemote: self.aRemote]);
}


- (void) testAliceSendBobReceive
{
    [self exchangeKeys];
    NSString *message1 = @"Test message 1 encrypted by Alice";
    NSData *alicesMessageData = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage = [self.axolotl encryptData: alicesMessageData forRecipient: self.bRemote];
    NSData *decryptedMessageData = [self.bxolotl decryptMessage: alicesMessage fromSender: self.aRemote];
    XCTAssert(decryptedMessageData);
    NSString *decryptedMessage = [[NSString alloc] initWithData: decryptedMessageData encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage);
}



@end
