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
 * Created by Raphael Arias on 8/13/14.
 */

#import "MOBTorInterface.h"
#import "TorController.h"
#import "MOBCore.h"

@class TorController;

@interface MOBTorInterface ()

@property (nonatomic, copy) ConnectSuccessfulBlock onConnect;

@property (nonatomic, copy) ConnectFailureBlock onFailure;

@end

@implementation MOBTorInterface

- (instancetype) initWithSettings: (id<MOBAnonymizerSettings>) aSettings
{
    if (self = [super init])
    {
        self.settings = aSettings;
        self.tor = [[TorController alloc] initWithDelegate: self];
    }
    return self;
}

- (void) connectOnFinishExecuteBlock: (ConnectSuccessfulBlock) aOnConnect
                             failure: (ConnectFailureBlock) aOnFailure
{
    self.onConnect = aOnConnect;
    self.onFailure = aOnFailure;
    // TODO: Add connection code here!
    [self.tor startTor];
}

- (void) notifyConnectionComplete
{
    // TODO: parameters
    DDLogDebug(@"connection complete!");
    self.onConnect();
    //dispatch_async(dispatch_get_main_queue(), self.onConnect);
}

- (void) notifyConnectionFailed
{
    // TODO: parameters
    dispatch_async( dispatch_get_main_queue(), self.onFailure);
}


@end
