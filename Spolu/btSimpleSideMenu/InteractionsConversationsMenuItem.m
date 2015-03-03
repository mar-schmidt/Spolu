//
//  InteractionsConversationsMenu.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "InteractionsConversationsMenuItem.h"

@implementation InteractionsConversationsMenuItem

-(id)initWithTitle:(NSString *)title image:(UIImage *)image onCompletion:(completion)completionBlock;
{
    self = [super init];
    if(self)
    {
        self.title = title;
        self.image = image;
        self.block = completionBlock;
        self.imageView = [[UIImageView alloc]initWithImage:image];
        self.imageView.frame = CGRectMake(0, 0, 40, 40);
    }
    
    return self;
}

@end
