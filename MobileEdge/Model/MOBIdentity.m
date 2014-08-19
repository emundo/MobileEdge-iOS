/*
 * Copyright (c) 2014 eMundo
 * All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * eMundo. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the licence agreement you
 * entered into with eMundo.
 *
 * Created by Luca Müller on 7/30/14.
 */

#import "MOBIdentity.h"

@implementation MOBIdentity

-(instancetype) init
{
    NACLAsymmetricKeyPair *newKeyPair = [NACLAsymmetricKeyPair keyPair];
    if (self = [super initWithPublicKey:newKeyPair.publicKey])
    {
        _identityKeyPair = newKeyPair;
    }
    return self;
}

-(instancetype) initWithKeyPair: (NACLAsymmetricKeyPair *) aKeyPair
{
    if (self = [super initWithPublicKey:aKeyPair.publicKey])
    {
        _identityKeyPair = aKeyPair;
    }
    return self;
}

/*
 * No support for NSCopying!
 */

@end
