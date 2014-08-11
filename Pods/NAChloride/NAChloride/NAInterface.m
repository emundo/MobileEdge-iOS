//
//  NAInterface.m
//  NACL
//
//  Created by Gabriel Handford on 1/16/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "NAInterface.h"

#include "crypto_secretbox.h"

const NSUInteger NASecretBoxKeySize = crypto_secretbox_KEYBYTES;
const NSUInteger NASecretBoxNonceSize = crypto_secretbox_NONCEBYTES;
