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
 * Created by Raphael Arias on 05/11/14.
 */

#import <Foundation/Foundation.h>


#define kMOBErrorDomainProtocol @"axolotl.protocol.error.domain"
#define kMOBErrorDomainAnonymizer @"tor.anonymizer.error.domain"

enum MOBProtocolErrorCode
{
    kMOBProtocolKeyExchangeMessageInvalid,
    kMOBProtocolNoSessionForRemote,
    kMOBProtocolMessageFormatInvalid,
    kMOBProtocolMessageDecryptionFailed
};

enum MOBAnonymizerErrorCode
{
    kMOBAnonymizerConnectionFailed
};

@interface MOBError : NSObject

+ (void) populateErrorObject: (NSError **) aError
                   forDomain: (NSString *) aErrorDomain
                   errorCode: (NSInteger) aErrorCode;

@end
