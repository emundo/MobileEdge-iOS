//
//  NAHMAC.h
//  NACL
//
//  Created by Gabriel Handford on 1/16/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "NAInterface.h"

typedef NS_ENUM (NSUInteger, NAHMACAlgorithm) {
  NAHMACAlgorithmSHA1 = 1,
  NAHMACAlgorithmSHA224,
  NAHMACAlgorithmSHA256,
  NAHMACAlgorithmSHA384,
  NAHMACAlgorithmSHA512,
  
  // SHA3
  NAHMACAlgorithmSHA3_256,
  NAHMACAlgorithmSHA3_384,
  NAHMACAlgorithmSHA3_512,
};

@interface NAHMAC : NSObject <NAHMAC>

@property NAHMACAlgorithm algorithm;

- (instancetype)initWithAlgorithm:(NAHMACAlgorithm)algorithm;

- (NSData *)HMACForKey:(NSData *)key data:(NSData *)data;

+ (NSData *)HMACForKey:(NSData *)key data:(NSData *)data algorithm:(NAHMACAlgorithm)algorithm;

@end
