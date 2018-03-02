//
//  HWTableViewDelegate.h
//  HWExtension
//
//  Created by houwen.wang on 2016/12/13.
//  Copyright © 2016年 houwen.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWTableViewBlocks.h"

@interface HWTableViewDelegate : NSObject<UITableViewDelegate>

// config block
@property (nonatomic, copy) ConfigCellHeightBlock heightForRowAtIndexPathBlock;    //
@property (nonatomic, copy) ConfigHeaderOrFooterHeightBlock heightForHeaderOrFooterInSectionBlock;    //
@property (nonatomic, copy) ConfigHeaderViewOrFooterViewBlock viewForHeaderOrFooterInSectionBlock;    //
@property (nonatomic, copy) ConfigDeleteConfirmationButtonTitleBlock titleForDeleteConfirmationButtonForRowAtIndexPathBlock;    //
@property (nonatomic, copy) ConfigEditActionsBlock editActionsForRowAtIndexPathBlock;       //
@property (nonatomic, copy) ConfigEditingStyleBlock editingStyleForRowAtIndexPathBlock;     //
@property (nonatomic, copy) ConfigCellIndentationLevelBlock indentationLevelForRowAtIndexPathBlock;     //

// enable block
@property (nonatomic, copy) ConfigEnableBlock shouldHighlightRowAtIndexPathBlock;             //
@property (nonatomic, copy) ConfigEnableBlock shouldIndentWhileEditingRowAtIndexPathBlock;    //
@property (nonatomic, copy) ConfigEnableBlock shouldShowMenuForRowAtIndexPathBlock;           //

// handler block
@property (nonatomic, copy) DisplayCellHandlerBlock displayCellForRowAtIndexPathHandlerBlock;                                 //
@property (nonatomic, copy) DisplayHeaderViewOrFooterViewHandlerBlock displayHeaderViewOrFooterViewForSectionHandlerBlock;    //
@property (nonatomic, copy) SelectOrDeselectRowHandlerBlock selectOrDeselectRowAtIndexPathHandlerBlock; //
@property (nonatomic, copy) HighlightOrUnhighlightRowHandlerBlock highlightOrUnhighlightRowAtIndexPathHandlerBlock; //
@property (nonatomic, copy) EditingRowHandlerBlock editingRowAtIndexPathCallbackHandlerBlock; //
@property (nonatomic, copy) AccessoryButtonTappedHandlerBlock accessoryButtonTappedForRowWithIndexPathHandlerBlock; //

@end
