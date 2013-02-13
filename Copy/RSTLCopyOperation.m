//
//  RSTLCopyOperation.m
//
//  Created by Doug Russell on 2/12/13.
//  Copyright (c) 2013 Doug Russell. All rights reserved.
//

#import "RSTLCopyOperation.h"

#include "copyfile.h"

@interface RSTLCopyOperation ()

@property (nonatomic) int resultCode;

@end

@implementation RSTLCopyOperation
{
    copyfile_state_t _copyfileState;
    RSTLCopyState _state;
}

- (instancetype)initWithFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    self = [super init];
    if (self)
    {
        _fromPath = [fromPath copy];
        _toPath = [toPath copy];
    }
    return self;
}

static int RSTLCopyFileCallback(int what, int stage, copyfile_state_t state, const char *fromPath, const char *toPath, void *context)
{
    RSTLCopyOperation *self = (__bridge RSTLCopyOperation *)context;
    if ([self isCancelled])
    {
        return COPYFILE_QUIT;
    }
    switch (what) {
        case COPYFILE_RECURSE_FILE:
            switch (stage) {
                case COPYFILE_START:
                    NSLog(@"File Start");
                    break;
                case COPYFILE_FINISH:
                    NSLog(@"File Finish");
                    break;
                case COPYFILE_ERR:
                    NSLog(@"File Error %i", errno);
                    break;
            }
            break;
        case COPYFILE_RECURSE_DIR:
            switch (stage) {
                case COPYFILE_START:
                    NSLog(@"Dir Start");
                    break;
                case COPYFILE_FINISH:
                    NSLog(@"Dir Finish");
                    break;
                case COPYFILE_ERR:
                    NSLog(@"Dir Error");
                    break;
            }
            break;
        case COPYFILE_RECURSE_DIR_CLEANUP:
            switch (stage) {
                case COPYFILE_START:
                    NSLog(@"Dir Cleanup Start");
                    break;
                case COPYFILE_FINISH:
                    NSLog(@"Dir Cleanup Finish");
                    break;
                case COPYFILE_ERR:
                    NSLog(@"Dir Cleanup Error");
                    break;
            }
            break;
        case COPYFILE_RECURSE_ERROR:
            
            break;
        case COPYFILE_COPY_XATTR:
            switch (stage) {
                case COPYFILE_START:
                    NSLog(@"Xattr Start");
                    break;
                case COPYFILE_FINISH:
                    NSLog(@"Xattr Finish");
                    break;
                case COPYFILE_ERR:
                    NSLog(@"Xattr Error");
                    break;
            }
            break;
        case COPYFILE_COPY_DATA:
            switch (stage) {
                case COPYFILE_PROGRESS:
                {
                    off_t copiedBytes;
                    const int returnCode = copyfile_state_get(state, COPYFILE_STATE_COPIED, &copiedBytes);
                    if (returnCode == 0)
                    {
                        NSLog(@"Copied %@ of %s so far", [NSByteCountFormatter stringFromByteCount:copiedBytes countStyle:NSByteCountFormatterCountStyleFile], fromPath);
                    }
                    else
                    {
                        NSLog(@"Could not retrieve copyfile state");
                    }
                    break;
                }
                case COPYFILE_ERR:
                    NSLog(@"Data Error");
                    break;
            }
            break;
    }
    return COPYFILE_CONTINUE;
    //return COPYFILE_SKIP;
    //return COPYFILE_QUIT;
}

- (int)flags
{
    // TODO: Figure out why COPYFILE_EXCL doesn't work for directories
    // Probably need to do something in the callback
    int flags = COPYFILE_ALL|COPYFILE_NOFOLLOW|COPYFILE_EXCL;
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.fromPath isDirectory:&isDir] && isDir)
    {
        flags |= COPYFILE_RECURSIVE;
    }
    return flags;
}

- (void)main
{
    NSLog(@"Will start copying");
    
    _copyfileState = copyfile_state_alloc();
    
    const char *fromPath = [self.fromPath fileSystemRepresentation];
    const char *toPath = [self.toPath fileSystemRepresentation];
    
    _state = RSTLCopyInProgress;
    
    copyfile_state_set(_copyfileState, COPYFILE_STATE_STATUS_CB, &RSTLCopyFileCallback);
    copyfile_state_set(_copyfileState, COPYFILE_STATE_STATUS_CTX, (__bridge void *)self);
    
    self.resultCode = copyfile(fromPath, toPath, _copyfileState, [self flags]);
    
    _state = RSTLCopyFinished;
    
    copyfile_state_free(_copyfileState);
    
    NSLog(@"Did finish copying with return code %d", self.resultCode);
}

@end
