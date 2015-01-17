//
//  BrowseViewController.h
//  MemoBox
//
//  Created by Sacha Best on 1/16/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowseCollectionViewCell.h"
#import "ParseManager.h"

@interface BrowseViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout> {
    float cellDimension;
}


@end