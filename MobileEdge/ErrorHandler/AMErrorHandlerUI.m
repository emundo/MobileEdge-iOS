//
//  PTPErrorHandlerUI.m
//  pickthatplace
//
//  Created by Alexander Mack on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AMErrorHandlerUI.h"

@implementation AMErrorHandlerUI

- (void)handleUnrecoverableErrorWithTitle:(NSString*)aTitle
                                  message:(NSString*)aMessage;
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:aTitle
                                                    message:aMessage 
                                                   delegate:nil 
                                          cancelButtonTitle:nil 
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)handleRecoverableErrorWithTitle:(NSString*)aTitle
                                message:(NSString*)aMessage;
{
    [self handleRecoverableErrorWithTitle:aTitle message:aMessage delegate:nil];
}

- (void)handleRecoverableErrorWithTitleKey:(NSString*)aTitleKey
                                messageKey:(NSString*)aMessageKey;
{
    NSString *title = NSLocalizedString(aTitleKey, @"");
    NSString *message = NSLocalizedString(aMessageKey, @"");
    [self handleRecoverableErrorWithTitle:title message:message];
}

- (void) handleRecoverableErrorWithCode:(AMRecoverableErrorCode) aErrorCode;
{
    [self handleRecoverableErrorWithCode:aErrorCode delegate:nil];
}

- (void) handleRecoverableErrorWithCode:(AMRecoverableErrorCode) aErrorCode
                               delegate:(id<UIAlertViewDelegate>) aDelegate;
{
    NSString *localizedTitleIdentifier = [NSString stringWithFormat:@"RecoverableError_Code_%i_Title", aErrorCode];
    
    NSString *localizedMessageIdentifier = [NSString stringWithFormat:@"RecoverableError_Code_%i_Message", aErrorCode];
    
    NSString *title = NSLocalizedString(localizedTitleIdentifier, @"");
    NSString *message = NSLocalizedString(localizedMessageIdentifier, @"");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:aDelegate
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)handleRecoverableErrorWithTitle:(NSString*)aTitle
                                message:(NSString*)aMessage
                               delegate:(id<UIAlertViewDelegate>) aDelegate;
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:aTitle
                                                    message:aMessage
                                                   delegate:aDelegate
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
