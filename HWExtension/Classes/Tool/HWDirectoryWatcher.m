//
//  HWDirectoryWatcher.m
//  HWExtension
//
//  Created by houwen.wang on 2016/11/24.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import "HWDirectoryWatcher.h"

@interface HWDirectoryWatcher () {
    int _dirFD;
    int _kq;
    CFFileDescriptorRef _dirKQRef;
}
@end

@implementation HWDirectoryWatcher

- (instancetype)init {
    if (self=[super init]) {
        self = [super init];
        _delegate = NULL;
        _dirFD = -1;
        _kq = -1;
        _dirKQRef = NULL;
    }
    return self;
}

- (void)dealloc {
    [self invalidate];
}

+ (HWDirectoryWatcher *)watchFolderWithPath:(NSString *)watchPath delegate:(id)watchDelegate {
    
    HWDirectoryWatcher *retVal = NULL;
    
    if ((watchDelegate != NULL) && (watchPath != NULL)) {
        HWDirectoryWatcher *tempManager = [[HWDirectoryWatcher alloc] init];
        tempManager.delegate = watchDelegate;
        
        if ([tempManager startMonitoringDirectory: watchPath]) {
            // Everything appears to be in order, so return the DirectoryWatcher.
            // Otherwise we'll fall through and return NULL.
            retVal = tempManager;
        }
    }
    return retVal;
}

#pragma mark - private

- (void)invalidate {
    if (_dirKQRef != NULL) {
        CFFileDescriptorInvalidate(_dirKQRef);
        CFRelease(_dirKQRef);
        _dirKQRef = NULL;
        // We don't need to close the kq, CFFileDescriptorInvalidate closed it instead.
        // Change the value so no one thinks it's still live.
        _kq = -1;
    }
    
    if(_dirFD != -1) {
        close(_dirFD);
        _dirFD = -1;
    }
}

- (void)kqueueFired {
    assert(_kq >= 0);
    struct kevent   event;
    struct timespec timeout = {0, 0};
    int             eventCount;
    
    eventCount = kevent(_kq, NULL, 0, &event, 1, &timeout);
    assert((eventCount >= 0) && (eventCount < 2));
    
    // call our delegate of the directory change
    [self.delegate directoryDidChange:self];
    CFFileDescriptorEnableCallBacks(_dirKQRef, kCFFileDescriptorReadCallBack);
}

static void KQCallback(CFFileDescriptorRef kqRef, CFOptionFlags callBackTypes, void *info) {
    HWDirectoryWatcher *obj;
    obj = (__bridge HWDirectoryWatcher *)info;
    assert([obj isKindOfClass:[HWDirectoryWatcher class]]);
    assert(kqRef == obj->_dirKQRef);
    assert(callBackTypes == kCFFileDescriptorReadCallBack);
    [obj kqueueFired];
}

- (BOOL)startMonitoringDirectory:(NSString *)dirPath {
    // Double initializing is not going to work...
    if ((_dirKQRef == NULL) && (_dirFD == -1) && (_kq == -1)) {
        
        // Open the directory we're going to watch
        _dirFD = open([dirPath fileSystemRepresentation], O_EVTONLY);
        
        if (_dirFD >= 0) {
            
            // Create a kqueue for our event messages...
            _kq = kqueue();
            
            if (_kq >= 0) {
                struct kevent eventToAdd;
                eventToAdd.ident  = _dirFD;
                eventToAdd.filter = EVFILT_VNODE;
                eventToAdd.flags  = EV_ADD | EV_CLEAR;
                eventToAdd.fflags = NOTE_WRITE;
                eventToAdd.data   = 0;
                eventToAdd.udata  = NULL;
                
                int errNum = kevent(_kq, &eventToAdd, 1, NULL, 0, NULL);
                if (errNum == 0) {
                    
                    CFFileDescriptorContext context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
                    CFRunLoopSourceRef      rls;
                    
                    // Passing true in the third argument so CFFileDescriptorInvalidate will close kq.
                    _dirKQRef = CFFileDescriptorCreate(NULL, _kq, true, KQCallback, &context);
                    
                    if (_dirKQRef != NULL) {
                        rls = CFFileDescriptorCreateRunLoopSource(NULL, _dirKQRef, 0);
                        
                        if (rls != NULL) {
                            CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
                            CFRelease(rls);
                            CFFileDescriptorEnableCallBacks(_dirKQRef, kCFFileDescriptorReadCallBack);
                            // If everything worked, return early and bypass shutting things down
                            return YES;
                        }
                        
                        // Couldn't create a runloop source, invalidate and release the CFFileDescriptorRef
                        CFFileDescriptorInvalidate(_dirKQRef);
                        CFRelease(_dirKQRef);
                        _dirKQRef = NULL;
                    }
                }
                // kq is active, but something failed, close the handle...
                close(_kq);
                _kq = -1;
            }
            // file handle is open, but something failed, close the handle...
            close(_dirFD);
            _dirFD = -1;
        }
    }
    return NO;
}

@end
