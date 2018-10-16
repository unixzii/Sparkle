//
//  SUBasicUpdateDriver+Private.h
//  Sparkle
//
//  Created by Yichen on 2018/10/16.
//  Copyright © 2018 Sparkle Project. All rights reserved.
//

#ifndef SUBASICUPDATEDRIVER_PRIVATE_H
#define SUBASICUPDATEDRIVER_PRIVATE_H

@protocol SUVersionComparison;
@interface SUBasicUpdateDriver ()

- (id<SUVersionComparison>)versionComparator;

@end

#endif
