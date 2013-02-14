//
//  RSTLCopyOperation.h
//
//  Created by Doug Russell on 2/12/13.
//  Copyright (c) 2013 Doug Russell. All rights reserved.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  

#import <Foundation/Foundation.h>

// Disclaimer: This implementation is mostly just a tinker toy.
// Copyfile is theoretically the replacement for the FS API that let you do copy operations and get progress callbacks,
// (https://developer.apple.com/library/mac/documentation/Carbon/Reference/File_Manager/DeprecationAppendix/AppendixADeprecatedAPI.html#//apple_ref/c/func/FSCopyObjectAsync)
// but it still has this in the header:

/*
 * this is an API to faciliatate copying of files and their
 * associated metadata.  There are several open source projects that
 * need modifications to support preserving extended attributes and
 * acls and this API collapses several hundred lines of modifications
 * into one or two calls.
 *
 * This implementation is incomplete and the interface may change in a 
 * future release.
 */

// and personally I think that any API with that in the header
// I wouldn't use in any real software.

typedef NS_ENUM(int8_t, RSTLCopyState) {
    RSTLCopyNotStarted,
    RSTLCopyInProgress,
    RSTLCopyFinished,
	RSTLCopyFailed,
};

@protocol RSTLCopyOperationDelegate;

@interface RSTLCopyOperation : NSOperation

@property (copy, nonatomic, readonly) NSString *fromPath;
@property (copy, nonatomic, readonly) NSString *toPath;

@property (readonly) RSTLCopyState state;
// Not valid until operation has finished
@property (readonly) int resultCode;

@property (weak) id<RSTLCopyOperationDelegate> delegate;

- (instancetype)initWithFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

@end

@protocol RSTLCopyOperationDelegate <NSObject>
@optional
- (void)copyOperationWillStart:(RSTLCopyOperation *)copyOperation;
- (void)copyOperationDidFinish:(RSTLCopyOperation *)copyOperation;
@end
