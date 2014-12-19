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
 * Created by Raphael Arias on 15/10/14.
 */

#import <Foundation/Foundation.h>
@class MOBRemoteIdentity, MOBIdentity;

/**
 * @discussion A type for the block that is used to pass a key exchange
 *  finalization block to the callback block KeyExchangeSendBlock.
 *  This block is created by the protocol library and should be called in
 *  the KeyExchangeSendBlock provided by the library user.
 */
typedef void (^KeyExchangeFinalizeBlock) (NSData *keyExchangeMessageIn);

/**
 * @discussion A type for the block that is needed by the method that
 *  performs a key exchange with Bob (whenever we initiate a key exchange).
 *  This block will be called by the library function and it must take care
 *  of sending the key exchange message it is passed to Bob. Afterwards it
 *  must call the finalizeBlock it receives to let the library finish 
 *  the key exchange.
 */
typedef void (^KeyExchangeSendBlock) (NSDictionary *keyExchangeMessage, KeyExchangeFinalizeBlock finalizeBlock);

/**
 * @discussion A type for the block that is needed by the method that
 *  performs a key exchange with Alice (whenever another entity initiates a key
 *  exchange with us).
 *  This block will be called by the library function and it must take care
 *  of sending the key exchange message it is passed to Alice.
 *  No finalizing block needs to be called in this case, as the library can
 *  finish the key exchange immediately.
 */
typedef void (^KeyExchangeSendBlockBob) (NSDictionary *keyExchangeMessage);


@protocol MOBProtocol <NSObject>

/**
 * @discussion Initialize a protocol instance using a given Identity.
 *  A protocol instance is always bound to one specific identity for ourselves.
 *  In a protocol instance we can gather individual sessions for various
 *  communication partners after exchanging keys with them.
 * @param identity - the own identity to use for the new protocol instance
 * @return the initialized protocol instance.
 */
- (instancetype) initWithIdentity: (MOBIdentity *) identity;

/**
 * @discussion Encrypt a given message for a given recipient.
 * @param aMessage - the message to encrypt
 * @param aRecipient - the receiver of the message
 * @param aError - an error object to set if encryption fails
 * @return the encrypted message or nil if encryption failed
 */
- (NSDictionary *) encryptString: (NSString *) aMessage
                    forRecipient: (MOBRemoteIdentity *) aRecipient
                           error: (NSError **) aError;

/**
 * @discussion Encrypt given data for a given recipient.
 * @param aData - the data to encrypt
 * @param aRecipient - the recipient
 * @param aError - an error object to set if encryption fails
 * @return the encrypted data as a dictionary to be used in a JSON object
 *  or nil if encryption does not succeed.
 */
- (NSDictionary *) encryptData: (NSData *) aData
                  forRecipient: (MOBRemoteIdentity *) aRecipient
                         error: (NSError **) aError;

/**
 * @discussion Decrypt a given message from a given sender
 * @param aEncryptedMessage - the encrypted message
 * @param aSender - the sender of the message
 * @param aError - an error object to set if decryption fails
 * @return the cleartext message if successful or nil if decryption failed
 */
- (NSData *) decryptMessage: (NSDictionary *) aEncryptedMessage
                 fromSender: (MOBRemoteIdentity *) aSender
                      error: (NSError **) aError;

/**
 * @discussion Decrypt given data from a given sender
 * @param aEncryptedData - the encrypted data
 * @param aSender - the sender of the data
 * @param aError - an error object to set if decryption fails
 * @return the cleartext string if successful or nil if decryption failed
 */
- (NSString *) decryptedStringFromMessage: (NSDictionary *) aEncryptedMessage
                               fromSender: (MOBRemoteIdentity *) aSender
                                    error: (NSError **) aError;

/**
 * @discussion Decrypts a given message, if a session can be found for the sender.
 * Note: The message object MUST contain the sender's identity encrypted with
 * our public key, else the decryption will fail. This function is provided as
 * a convenience function to client applications that don't want to manage
 * identities themselves.
 * @param aEncryptedMessage - the encrypted message including (!) encrypted sender
 *  information.
 * @param aError - an error object to set if decryption fails
 * @return the decrypted data or nil if decryption fails
 */
- (NSData *) decryptMessage: (NSDictionary *) aEncryptedMessage
                      error: (NSError **) aError;


/**
 * @discussion Checks whether a session exists for a given remote.
 * @param aBob - Bob's identity
 * @return YES if it exists, else NO
 */
- (BOOL) hasSessionForRemote: (MOBRemoteIdentity *) aBob;

/**
 * @discussion Perform an Axolotl key agreement with a given peer.
 *  This will usually be the MobileEdge server or a vendor identity.
 * @param aBob - Bob's identity
 * @param aSendKeyExchangeBlock - the block we should use to send a key exchange
 *  message.
 *  This block will be called by the library function and it must take care
 *  of sending the key exchange message it is passed to Alice.
 *  No finalizing block needs to be called in this case, as the library can
 *  finish the key exchange immediately.
 * @param aError - an error object to set if the key exchange cannot be completed.
 */
- (void) performKeyExchangeWithBob: (MOBRemoteIdentity *) aBob
    andSendKeyExchangeMessageUsing: (KeyExchangeSendBlock) aSendKeyExchangeBlock
                             error: (NSError **) aError;

/**
 * @discussion Perform a key exchange with someone who initiated a key exchange
 * with us.
 * @param aAlice - Alice's identity.
 * @param aTheirKeyExchangeMessage - the key exchange message we received.
 * @param aSendKeyExchangeBlock - the block we should use to send our key exchange
 *  message.
 *  This block will be called by the library function and it must take care
 *  of sending the key exchange message it is passed to Alice.
 *  No finalizing block needs to be called in this case, as the library can
 *  finish the key exchange immediately.
 * @param aError - an error object to set if the key exchange cannot be completed.
 */
- (void) performKeyExchangeWithAlice: (MOBRemoteIdentity *) aAlice
             usingKeyExchangeMessage: (NSData *) aTheirKeyExchangeMessage
      andSendKeyExchangeMessageUsing: (KeyExchangeSendBlockBob) aSendKeyExchangeBlock
                               error: (NSError **) aError;

@end
