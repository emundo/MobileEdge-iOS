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
    
    self.alice = nil;
    self.bob   = nil;
    self.axolotl = nil;
    self.bxolotl = nil;
    
    self.aRemote = nil;
    self.bRemote = nil;
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
                   andSendKeyExchangeMessageUsing: bobsSendingBlock
                                            error: nil];
    };
    
    [self.axolotl performKeyExchangeWithBob: self.bRemote andSendKeyExchangeMessageUsing: alicesSendingBlock error: nil];
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

- (void) testBobSendAliceReceive
{
    [self exchangeKeys];
    NSString *message1 = @"Test message 1 encrypted by Bob.";
    NSData *bobsMessageData = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage = [self.bxolotl encryptData: bobsMessageData forRecipient: self.aRemote error: nil];
    NSData *decryptedMessageData = [self.axolotl decryptMessage: bobsMessage fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage = [[NSString alloc] initWithData: decryptedMessageData encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage);
}

- (void) testAliceSendBobReceive
{
    [self exchangeKeys];
    NSString *message1 = @"Test message 1 encrypted by Alice";
    NSData *alicesMessageData = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage = [self.axolotl encryptData: alicesMessageData forRecipient: self.bRemote error: nil];
    NSData *decryptedMessageData = [self.bxolotl decryptMessage: alicesMessage fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage = [[NSString alloc] initWithData: decryptedMessageData encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage);
}

- (void) testBobSend1BobSend2AliceReceive1AliceReceive2
{
    [self exchangeKeys];
    NSString *message1 = @"Test message 1 encrypted by Bob.";
    NSData *bobsMessageData = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage = [self.bxolotl encryptData: bobsMessageData forRecipient: self.aRemote error: nil];
    NSData *decryptedMessageData = [self.axolotl decryptMessage: bobsMessage fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage = [[NSString alloc] initWithData: decryptedMessageData encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage);
    
    NSString *message2 = @"Test message 2 encrypted by Bob.";
    bobsMessageData = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    bobsMessage = [self.bxolotl encryptData: bobsMessageData forRecipient: self.aRemote error: nil];
    decryptedMessageData = [self.axolotl decryptMessage: bobsMessage fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData, @"Decrypted message data should not be nil/NULL.");
    decryptedMessage = [[NSString alloc] initWithData: decryptedMessageData encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage isEqualToString: message1], @"Original: %@, Decrypted: %@", message2, decryptedMessage);
}

- (void) testAliceSend1AliceSend2BobReceive1BobReceive2
{
    [self exchangeKeys];
    NSString *message1 = @"Test message 1 encrypted by Alice";
    NSData *alicesMessageData = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage = [self.axolotl encryptData: alicesMessageData forRecipient: self.bRemote error: nil];
    NSData *decryptedMessageData = [self.bxolotl decryptMessage: alicesMessage fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage = [[NSString alloc] initWithData: decryptedMessageData encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage);
    
    NSString *message2 = @"Test message 2 encrypted by Alice";
    alicesMessageData = [message2 dataUsingEncoding: NSUTF8StringEncoding];
    alicesMessage = [self.axolotl encryptData: alicesMessageData forRecipient: self.bRemote error: nil];
    decryptedMessageData = [self.bxolotl decryptMessage: alicesMessage fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData, @"Decrypted message data should not be nil/NULL.");
    decryptedMessage = [[NSString alloc] initWithData: decryptedMessageData encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage isEqualToString: message2], @"Original: %@, Decrypted: %@", message2, decryptedMessage);
}

- (void) testBobSend1BobSend2AliceReceive2AliceReceive1
{
    [self exchangeKeys];
 
    NSString *message1 = @"Test message 1 encrypted by Bob.";
    NSString *message2 = @"Test message 2 encrypted by Bob.";
    
    NSData *bobsMessageData1 = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage1 = [self.bxolotl encryptData: bobsMessageData1 forRecipient: self.aRemote error: nil];
    NSData *bobsMessageData2 = [message2 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage2 = [self.bxolotl encryptData: bobsMessageData2 forRecipient: self.aRemote error: nil];
    
    NSData *decryptedMessageData2 = [self.axolotl decryptMessage: bobsMessage2 fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData2, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage2 = [[NSString alloc] initWithData: decryptedMessageData2 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage2 isEqualToString: message2], @"Original: %@, Decrypted: %@", message2, decryptedMessage2);
    
    NSData *decryptedMessageData1 = [self.axolotl decryptMessage: bobsMessage1 fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData1, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage1 = [[NSString alloc] initWithData: decryptedMessageData1 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage1 isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage1);
}

- (void) testAliceSend1AliceSend2BobReceive2BobReceive1
{
    [self exchangeKeys];
    
    NSString *message1 = @"Test message 1 encrypted by Alice";
    NSString *message2 = @"Test message 2 encrypted by Alice";
    
    NSData *alicesMessageData1 = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage1 = [self.axolotl encryptData: alicesMessageData1 forRecipient: self.bRemote error: nil];
    NSData *alicesMessageData2 = [message2 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage2 = [self.axolotl encryptData: alicesMessageData2 forRecipient: self.bRemote error: nil];
    
    NSData *decryptedMessageData2 = [self.bxolotl decryptMessage: alicesMessage2 fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData2, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage2 = [[NSString alloc] initWithData: decryptedMessageData2 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage2 isEqualToString: message2], @"Original: %@, Decrypted: %@", message2, decryptedMessage2);
    
    NSData *decryptedMessageData1 = [self.bxolotl decryptMessage: alicesMessage1 fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData1, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage1 = [[NSString alloc] initWithData: decryptedMessageData1 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage1 isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage1);
}

- (void) testBobSend1AliceReceive1AliceSend2BobReceive2
{
    [self exchangeKeys];
 
    NSString *message1 = @"Test message 1 encrypted by Bob.";
    NSString *message2 = @"Test message 2 encrypted by Alice.";
    
    NSData *bobsMessageData1 = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage1 = [self.bxolotl encryptData: bobsMessageData1 forRecipient: self.aRemote error: nil];
    
    NSData *decryptedMessageData1 = [self.axolotl decryptMessage: bobsMessage1 fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData1, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage1 = [[NSString alloc] initWithData: decryptedMessageData1 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage1 isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage1);
    
    NSData *alicesMessageData2 = [message2 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage2 = [self.axolotl encryptData: alicesMessageData2 forRecipient: self.bRemote error: nil];
    
    NSData *decryptedMessageData2 = [self.bxolotl decryptMessage: alicesMessage2 fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData2, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage2 = [[NSString alloc] initWithData: decryptedMessageData2 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage2 isEqualToString: message2], @"Original: %@, Decrypted: %@", message2, decryptedMessage2);
}

- (void) testAliceSend1BobReceive1BobSend2AliceReceive2
{
    [self exchangeKeys];
 
    NSString *message1 = @"Test message 1 encrypted by Alice.";
    NSString *message2 = @"Test message 2 encrypted by Bob.";
    
    NSData *alicesMessageData1 = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage1 = [self.axolotl encryptData: alicesMessageData1 forRecipient: self.bRemote error: nil];
    
    NSData *decryptedMessageData1 = [self.bxolotl decryptMessage: alicesMessage1 fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData1, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage1 = [[NSString alloc] initWithData: decryptedMessageData1 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage1 isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage1);
    
    NSData *bobsMessageData2 = [message2 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage2 = [self.bxolotl encryptData: bobsMessageData2 forRecipient: self.aRemote error: nil];
    
    NSData *decryptedMessageData2 = [self.axolotl decryptMessage: bobsMessage2 fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData2, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage2 = [[NSString alloc] initWithData: decryptedMessageData2 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage2 isEqualToString: message2], @"Original: %@, Decrypted: %@", message2, decryptedMessage2);
}

- (void) testBobSend1AliceSend2AliceReceive1BobReceive2
{
    [self exchangeKeys];
 
    NSString *message1 = @"Test message 1 encrypted by Bob.";
    NSString *message2 = @"Test message 2 encrypted by Alice.";
    
    NSData *bobsMessageData1 = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage1 = [self.bxolotl encryptData: bobsMessageData1 forRecipient: self.aRemote error: nil];
    
    NSData *alicesMessageData2 = [message2 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage2 = [self.axolotl encryptData: alicesMessageData2 forRecipient: self.bRemote error: nil];
    
    NSData *decryptedMessageData1 = [self.axolotl decryptMessage: bobsMessage1 fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData1, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage1 = [[NSString alloc] initWithData: decryptedMessageData1 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage1 isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage1);
    
    NSData *decryptedMessageData2 = [self.bxolotl decryptMessage: alicesMessage2 fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData2, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage2 = [[NSString alloc] initWithData: decryptedMessageData2 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage2 isEqualToString: message2], @"Original: %@, Decrypted: %@", message2, decryptedMessage2);
}

- (void) testAliceSend1BobSend2BobReceive1AliceReceive2
{
    [self exchangeKeys];
 
    NSString *message1 = @"Test message 1 encrypted by Alice.";
    NSString *message2 = @"Test message 2 encrypted by Bob.";
    
    NSData *alicesMessageData1 = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage1 = [self.axolotl encryptData: alicesMessageData1 forRecipient: self.bRemote error: nil];
    
    NSData *bobsMessageData2 = [message2 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage2 = [self.bxolotl encryptData: bobsMessageData2 forRecipient: self.aRemote error: nil];
    
    NSData *decryptedMessageData1 = [self.bxolotl decryptMessage: alicesMessage1 fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData1, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage1 = [[NSString alloc] initWithData: decryptedMessageData1 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage1 isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage1);
    
    NSData *decryptedMessageData2 = [self.axolotl decryptMessage: bobsMessage2 fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData2, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage2 = [[NSString alloc] initWithData: decryptedMessageData2 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage2 isEqualToString: message2], @"Original: %@, Decrypted: %@", message2, decryptedMessage2);
}

- (void) testBobSend1AliceSend2BobReceive2BobSend3AliceReceive3AliceReceive1
{
    [self exchangeKeys];
 
    NSString *message1 = @"Test message 1 encrypted by Bob.";
    NSString *message2 = @"Test message 2 encrypted by Alice.";
    NSString *message3 = @"Test message 3 encrypted by Bob.";
    
    NSData *bobsMessageData1 = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage1 = [self.bxolotl encryptData: bobsMessageData1 forRecipient: self.aRemote error: nil];
    
    NSData *alicesMessageData2 = [message2 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage2 = [self.axolotl encryptData: alicesMessageData2 forRecipient: self.bRemote error: nil];
    
    NSData *decryptedMessageData2 = [self.bxolotl decryptMessage: alicesMessage2 fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData2, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage2 = [[NSString alloc] initWithData: decryptedMessageData2 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage2 isEqualToString: message2], @"Original: %@, Decrypted: %@", message2, decryptedMessage2);
    
    NSData *bobsMessageData3 = [message3 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage3 = [self.bxolotl encryptData: bobsMessageData3 forRecipient: self.aRemote error: nil];
    
    NSData *decryptedMessageData3 = [self.axolotl decryptMessage: bobsMessage3 fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData3, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage3 = [[NSString alloc] initWithData: decryptedMessageData3 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage3 isEqualToString: message3], @"Original: %@, Decrypted: %@", message3, decryptedMessage3);
    
    NSData *decryptedMessageData1 = [self.axolotl decryptMessage: bobsMessage1 fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData1, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage1 = [[NSString alloc] initWithData: decryptedMessageData1 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage1 isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage1);
}

- (void) testAliceSend1BobSend2AliceReceive2AliceSend3BobReceive3BobReceive1
{
    [self exchangeKeys];
 
    NSString *message1 = @"Test message 1 encrypted by Alice.";
    NSString *message2 = @"Test message 2 encrypted by Bob.";
    NSString *message3 = @"Test message 3 encrypted by Alice.";
    
    NSData *alicesMessageData1 = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage1 = [self.axolotl encryptData: alicesMessageData1 forRecipient: self.bRemote error: nil];
    
    NSData *bobsMessageData2 = [message2 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage2 = [self.bxolotl encryptData: bobsMessageData2 forRecipient: self.aRemote error: nil];
    
    NSData *decryptedMessageData2 = [self.axolotl decryptMessage: bobsMessage2 fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData2, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage2 = [[NSString alloc] initWithData: decryptedMessageData2 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage2 isEqualToString: message2], @"Original: %@, Decrypted: %@", message2, decryptedMessage2);
    
    NSData *alicesMessageData3 = [message3 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *alicesMessage3 = [self.axolotl encryptData: alicesMessageData3 forRecipient: self.bRemote error: nil];
    
    NSData *decryptedMessageData3 = [self.bxolotl decryptMessage: alicesMessage3 fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData3, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage3 = [[NSString alloc] initWithData: decryptedMessageData3 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage3 isEqualToString: message3], @"Original: %@, Decrypted: %@", message3, decryptedMessage3);
    
    NSData *decryptedMessageData1 = [self.bxolotl decryptMessage: alicesMessage1 fromSender: self.aRemote error: nil];
    XCTAssert(decryptedMessageData1, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage1 = [[NSString alloc] initWithData: decryptedMessageData1 encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage1 isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage1);
}

- (void) testBobSendAliceReceiveNoSenderSpecified
{
    [self exchangeKeys];
    NSString *message1 = @"Test message 1 encrypted by Bob.";
    NSData *bobsMessageData = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage = [self.bxolotl encryptData: bobsMessageData forRecipient: self.aRemote error: nil];
    NSData *decryptedMessageData = [self.axolotl decryptMessage: bobsMessage error: nil];
    XCTAssert(decryptedMessageData, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage = [[NSString alloc] initWithData: decryptedMessageData encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage);
}

- (void) testSerializationDeserialization
{
    [self exchangeKeys];
    self.axolotl = nil;
    self.axolotl = [[MOBAxolotl alloc] initWithIdentity: self.alice];
    
    NSString *message1 = @"Test message 1 encrypted by Bob.";
    NSData *bobsMessageData = [message1 dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bobsMessage = [self.bxolotl encryptData: bobsMessageData forRecipient: self.aRemote error: nil];
    NSData *decryptedMessageData = [self.axolotl decryptMessage: bobsMessage fromSender: self.bRemote error: nil];
    XCTAssert(decryptedMessageData, @"Decrypted message data should not be nil/NULL.");
    NSString *decryptedMessage = [[NSString alloc] initWithData: decryptedMessageData encoding: NSUTF8StringEncoding];
    XCTAssert([decryptedMessage isEqualToString: message1], @"Original: %@, Decrypted: %@", message1, decryptedMessage);
}

@end
