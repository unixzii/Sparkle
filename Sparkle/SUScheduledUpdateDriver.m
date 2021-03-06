//
//  SUScheduledUpdateDriver.m
//  Sparkle
//
//  Created by Andy Matuschak on 5/6/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUScheduledUpdateDriver.h"
#import "SUBasicUpdateDriver+Private.h"
#import "SUUpdaterPrivate.h"
#import "SUUpdaterDelegate.h"
#import "SUHost.h"
#import "SUAppcastItem.h"
#import "SUVersionComparisonProtocol.h"

@interface SUScheduledUpdateDriver ()

@end

@implementation SUScheduledUpdateDriver

- (instancetype)initWithUpdater:(id<SUUpdaterPrivate>)anUpdater
{
    if ((self = [super initWithUpdater:anUpdater])) {
        self.showErrors = NO;
    }
    return self;
}

- (void)didFindValidUpdate
{
    if (self.updateItem.silentAfterVersion) {
        NSString *silentAfterVersion = self.updateItem.silentAfterVersion;
        id<SUVersionComparison> comparator = [self versionComparator];
        if ([comparator compareVersion:self.host.version toVersion:silentAfterVersion] == NSOrderedDescending) {
            self.updateSilently = YES;
        }
    }
    
    self.showErrors = YES; // We only start showing errors after we present the UI for the first time.
    [super didFindValidUpdate];
}

- (void)didNotFindUpdate
{
    id<SUUpdaterPrivate> updater = self.updater;
    id<SUUpdaterDelegate> updaterDelegate = [updater delegate];

    if ([updaterDelegate respondsToSelector:@selector(updaterDidNotFindUpdate:)]) {
        [updaterDelegate updaterDidNotFindUpdate:self.updater];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SUUpdaterDidNotFindUpdateNotification object:self.updater];

    [self abortUpdate]; // Don't tell the user that no update was found; this was a scheduled update.
}

- (BOOL)shouldDisableKeyboardShortcutForInstallButton {
    return YES;
}

@end
