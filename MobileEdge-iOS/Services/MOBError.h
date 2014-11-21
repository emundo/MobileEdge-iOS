/*
 * Copyright (c) 2014 eMundo
 * All Rights Reserved.
 *
 * This file is part of MobileEdge-iOS.
 * MobileEdge-iOS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MobileEdge-iOS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with MobileEdge-iOS.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Created by Raphael Arias on 05/11/14.
 */

#import <Foundation/Foundation.h>

/**
 * Error domain for Protocol-related errors.
 */
#define kMOBErrorDomainProtocol @"emundo.mobileedge.ProtocolErrorDomain"

/**
 * Error domain for Anonymizer-related errors.
 */
#define kMOBErrorDomainAnonymizer @"emundo.mobileedge.AnonymizerErrorDomain"

/**
 * Error codes for protocol-related errors.
 */
enum MOBProtocolErrorCode
{
    kMOBProtocolKeyExchangeMessageInvalid,
    kMOBProtocolNoSessionForRemote,
    kMOBProtocolNoSenderInformation,
    kMOBProtocolIncorrectSenderInformation,
    kMOBProtocolMessageFormatInvalid,
    kMOBProtocolMessageDecryptionFailed,
    kMOBAxolotlRatchetFlagSetUnexpectedly,
    kMOBAxolotlExceedingSkippedMessageLimit
};

/**
 * Error codes for anonymizer-related errors.
 */
enum MOBAnonymizerErrorCode
{
    kMOBAnonymizerConnectionFailed
};

/**
 * A utility Error class used by MobileEdge internally to populate NSError objects.
 */
@interface MOBError : NSObject

/**
 * @discussion Populate an error object that might have been passed into the library.
 * @param aError - the error object pointer (can be nil)
 * @param aErrorDomain - the error domain.
 * @param aErrorCode - the error code.
 */
+ (void) populateErrorObject: (NSError **) aError
                   forDomain: (NSString *) aErrorDomain
                   errorCode: (NSInteger) aErrorCode;

@end
