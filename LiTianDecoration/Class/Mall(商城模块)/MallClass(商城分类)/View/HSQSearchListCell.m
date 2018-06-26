//
//  HSQSearchListCell.m
//  LiTianDecoration
//
//  Created by administrator on 2018/5/3.
//  Copyright © 2018年 administrator. All rights reserved.
//

#import "HSQSearchListCell.h"

@interface HSQSearchListCell ()

@end

@implementation HSQSearchListCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        UILabel *nameLabel = [[UILabel alloc] init];
        
        nameLabel.font = [UIFont systemFontOfSize:12.0];
        
        nameLabel.textColor = RGB(51, 51, 51);
        
        [self.contentView addSubview:nameLabel];
        
        self.nameLabel = nameLabel;
        
        self.nameLabel.sd_layout.leftSpaceToView(self.contentView, 5).rightSpaceToView(self.contentView, 5).centerYEqualToView(self.contentView).heightIs(30);
    }
    
    return self;
}

@end
