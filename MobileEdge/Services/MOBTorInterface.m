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

@interface MOBTorInterface ()

@property (nonatomic, assign) ConnectSuccessfulBlock onConnect;

@property (nonatomic, assign) ConnectFailureBlock onFailure;

@property (nonatomic, retain) id <MOBAnonymizerSettings> settings;

@end

@implementation MOBTorInterface

- (instancetype) initWithSettings: (id<MOBAnonymizerSettings>) aSettings
{
    if (self = [super init])
    {
        self.settings = aSettings;
    }
    return self;
}

- (void) connectOnFinishExecuteBlock: (ConnectSuccessfulBlock) aOnConnect
                             failure: (ConnectFailureBlock) aOnFailure
{
    // TODO: Add connection code here!
    self.onConnect = aOnConnect;
    self.onFailure = aOnFailure;
}

- (void) notifyConnectionComplete
{
    // TODO: parameters
    self.onConnect();
}

- (void) notifyConnectionFailed
{
    // TODO: parameters
    self.onFailure();
}


@end
