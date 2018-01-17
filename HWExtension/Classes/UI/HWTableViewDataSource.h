//
//  HWTableViewDataSource.h
//  HWExtension
//
//  Created by houwen.wang on 2016/12/13.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWTableViewBlocks.h"

@interface HWTableViewDataSource : NSObject<UITableViewDataSource>

//
@property (nonatomic, copy) ConfigCellBlock cellForRowAtIndexPathBlock;                              // cell
@property (nonatomic, copy) ConfigNumberBlock numberOfSectionsBlock;                                 // number Of Sections
@property (nonatomic, copy) ConfigNumberBlock numberOfRowsInSectionBlock;                            // number Of Rows
@property (nonatomic, copy) ConfigHeaderOrFooterTitleBlock titleForHeaderOrFooterInSectionBlock;     // title Of Section
@property (nonatomic, copy) ConfigSectionIndexTitlesBlock sectionIndexTitlesBlock;                   // sectionIndex Titles
@property (nonatomic, copy) ConfigSectionForSectionIndexTitleBlock sectionForSectionIndexTitleBlock; // section For Section Index and Title

// enable
@property (nonatomic, copy) ConfigEnableBlock canEditRowAtIndexPathBlock;           // canEdit Row At IndexPath
@property (nonatomic, copy) ConfigEnableBlock canMoveRowAtIndexPathBlock;           // canMove Row At IndexPath

// edit callback block
@property (nonatomic, copy) CommitEditingCallbackBlock commitEditingRowAtIndexPathCallbackBlock;  // commitEditing callback
@property (nonatomic, copy) MoveRowCallbackBlock moveRowAtIndexPathCallbackBlock;                 // moveRow callback

@end
