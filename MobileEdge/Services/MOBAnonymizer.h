//
//  MOBAnonymizer.h
//  MobileEdge
//
//  Created by Raphael Arias on 11/11/14.
//  Copyright (c) 2014 eMundo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOBAnonymizerSettings.h"


typedef void (^ConnectSuccessfulBlock) (/* Parameters */);
typedef void (^ConnectFailureBlock) (/* Parameters */);


@protocol MOBAnonymizer <NSObject>

- (instancetype) initWithSettings: (id <MOBAnonymizerSettings>) settings;

- (void) connectOnFinishExecuteBlock: (ConnectSuccessfulBlock) aOnConnect
                             failure: (ConnectFailureBlock) aOnFailure;

- (void) notifyConnectionComplete;

@end
