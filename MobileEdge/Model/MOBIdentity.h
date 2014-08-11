//
//  MOBIDObject.h
//  MOBviewTest
//
//  Created by luc  on 30.07.14.
//  Copyright (c) 2014 BOSS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOBIdentity : NSObject

@property (nonatomic, retain) NSString *ttl;
@property (nonatomic, retain) NSString *nonce;
@property (nonatomic, retain) NSString *mac;
@property (nonatomic, retain) NSString *creationDate;

@end
