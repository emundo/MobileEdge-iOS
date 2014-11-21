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
 * Created by Raphael Arias on 04/11/14.
 */

#import "HKDFKit.h"

@interface HKDFKit (Strings)

/**
 * @discussion Allow strings as info and salt in HKDFKit.
 * @param seed - the seed.
 * @param info - the info string.
 * @param salt - the salt string.
 * @param outputSize - the size of key material to output.
 * @return the derived key material
 */
+ (NSData *) deriveKey: (NSData *) seed
            infoString: (NSString *) info
            saltString: (NSString *) salt
            outputSize: (int) outputSize;

@end
