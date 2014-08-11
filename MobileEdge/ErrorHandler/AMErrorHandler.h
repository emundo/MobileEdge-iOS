//
//  AMErrorHandler.h
//  PickThatPlace
//
//  Created by Alexander Mack on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 AMErrorHandler needs a localized Strings file called Error Messages to handle the standard recoverable error codes AMRecoverableErrorCode.
 The error codes are looked up via 
 NSLocalizedStringFromTable("RecoverableError_Code_%i_Title, ErrorMessages, @"")
 while i is the int value of the AMRecoverableErrorCode,
 */

typedef enum {
    AMRecoverableErrorCodeNoFacebook = 0,
    AMRecoverableErrorCodeNoMail = 1,
    AMRecoverableErrorCodeNoTwitter = 2,
    AMRecoverableErrorCodeNoCalendarAccess = 3,
    AMRecoverableErrorCodeNoAddressBookAccess = 4
} AMRecoverableErrorCode;

@protocol AMErrorHandler <NSObject>

- (void)handleUnrecoverableErrorWithTitle:(NSString*)aTitle
                                  message:(NSString*)aMessage;

- (void)handleRecoverableErrorWithTitle:(NSString*)aTitle
                                  message:(NSString*)aMessage;

- (void)handleRecoverableErrorWithTitle:(NSString*)aTitle
                                message:(NSString*)aMessage
                               delegate:(id<UIAlertViewDelegate>) aDelegate;



- (void) handleRecoverableErrorWithCode:(AMRecoverableErrorCode) aErrorCode;


- (void) handleRecoverableErrorWithCode:(AMRecoverableErrorCode) aErrorCode
                               delegate:(id<UIAlertViewDelegate>) aDelegate;

@end
