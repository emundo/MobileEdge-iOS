//
//  MOBAxolotlSession.h
//  MobileEdge
//
//  Created by Raphael Arias on 8/12/14.
//  Copyright (c) 2014 eMundo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOBAxolotlSession : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSData *myIdentityKey;  //FIXME: type should later be NACLAsymmetricKeyPair
@property (nonatomic, strong, readonly) NSData *theirIdentityKey;  //FIXME: type should later be NACLAsymmetricPublicKey
@property (nonatomic, strong, readonly) NSData *rootKey;

@property (nonatomic, strong, readonly) NSData *senderChainKey;
@property (nonatomic, strong, readonly) NSData *senderHeaderKey;
@property (nonatomic, strong, readonly) NSData *senderNextHeaderKey;
@property (nonatomic, strong, readonly) NSData *senderDiffieHellmanKey; //FIXME: type

@property (nonatomic, strong, readonly) NSData *receiverChainKey;
@property (nonatomic, strong, readonly) NSData *receiverHeaderKey;
@property (nonatomic, strong, readonly) NSData *receiverNextHeaderKey;
@property (nonatomic, strong, readonly) NSData *receiverDiffieHellmanKey; //FIXME: type

@property (nonatomic, assign, readonly) NSUInteger messagesReceivedCount;
@property (nonatomic, assign, readonly) NSUInteger messagesSentCount;
@property (nonatomic, assign, readonly) NSUInteger messagesSentUnderPreviousRatchetCount;

@property (nonatomic, assign, readonly) BOOL ratchetFlag;
@property (nonatomic, strong, readonly) NSMutableDictionary *skippedHeaderAndMessageKeys;

@end
