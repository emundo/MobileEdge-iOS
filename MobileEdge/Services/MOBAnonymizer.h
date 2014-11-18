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
 * Created by Raphael Arias on 11/11/14.
 */

#import <Foundation/Foundation.h>
#import "MOBAnonymizerSettings.h"


typedef void (^ConnectSuccessfulBlock) (/* Parameters */);
typedef void (^ConnectFailureBlock) (/* Parameters */);


@protocol MOBAnonymizer <NSObject>

- (id <MOBAnonymizerSettings>) settings;

/**
 * @discussion initializes an Anonymizer with some settings
 * @param aSettings - the settings to initialize the anonymizer with
 * @return a newly initialized Anonymizer
 */
- (instancetype) initWithSettings: (id <MOBAnonymizerSettings>) aSettings;

/**
 * @discussion Start connection to the anonymizing network. The onConnect or
 *  onFailure blocks are called once connection is complete.
 * @param aOnConnect - the block to be executed when connection was successful
 * @param aOnFailure - the block to be executed when connection fails for some reason
 */
- (void) connectOnFinishExecuteBlock: (ConnectSuccessfulBlock) aOnConnect
                             failure: (ConnectFailureBlock) aOnFailure;


@end
