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

#import "MOBError.h"

@implementation MOBError

+ (void) populateErrorObject: (NSError **) aError
                   forDomain: (NSString *) aErrorDomain
                   errorCode: (NSInteger) aErrorCode
{
    if (!aError)
    {
        return;
    }
    NSString *localizedDescription;
    if ([aErrorDomain isEqualToString: kMOBErrorDomainProtocol])
    {
        switch (aErrorCode)
        {
            case kMOBProtocolKeyExchangeMessageInvalid:
                localizedDescription = @"The key exchange message received from the remote was invalid.";
                break;
            case kMOBProtocolMessageFormatInvalid:
                localizedDescription = @"The message received from the remote has an invalid format.";
                break;
            case kMOBProtocolNoSessionForRemote:
                localizedDescription = @"No session for the given remote in this protocol instance.";
                break;
            case kMOBProtocolMessageDecryptionFailed:
                localizedDescription = @"Message was undecryptable.";
                break;
            case kMOBProtocolNoSenderInformation:
                localizedDescription = @"Cannot decrypt a message without information about its sender.";
                break;
            case kMOBProtocolIncorrectSenderInformation:
                localizedDescription = @"The sender information given could not be decrypted.";
                break;
            case kMOBAxolotlRatchetFlagSetUnexpectedly:
                localizedDescription = @"The ratchet flag was set unexpectedly. This should not happen whe decryption with current header key failed.";
                break;
            case kMOBAxolotlExceedingSkippedMessageLimit:
                localizedDescription = @"The received message is more than 500 messages into the future. Aborting decryption.";
                break;
                
            default:
                localizedDescription = @"An unknown error occurred.";
                break;
        }
    }
    else if ([aErrorDomain isEqualToString: kMOBErrorDomainAnonymizer])
    {
        switch (aErrorCode) {
            case kMOBAnonymizerConnectionFailed:
                localizedDescription = @"Could not connect to anonymizing network.";
                break;
                
            default:
                localizedDescription = @"An unknown error occurred.";
                break;
        }
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject: localizedDescription
                                                         forKey: NSLocalizedDescriptionKey];
    *aError = [NSError errorWithDomain: aErrorDomain code: aErrorCode userInfo: userInfo];
}

@end
