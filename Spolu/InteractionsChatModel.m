//
//  InteractionsChatModel.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "InteractionsChatModel.h"
#import "IRMessage.h"
#import "IRMessageFrame.h"

@implementation InteractionsChatModel

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

- (void)populateRandomDataSource {
    self.dataSource = [NSMutableArray array];
    [self.dataSource addObjectsFromArray:[self additems:2]];
}

- (void)addRandomItemsToDataSource:(NSInteger)number{
    
    for (int i=0; i<number; i++) {
        [self.dataSource insertObject:[[self additems:1] firstObject] atIndex:0];
    }
}

- (void)addSpecifiedItem:(NSDictionary *)dic
{
    IRMessageFrame *messageFrame = [[IRMessageFrame alloc]init];
    IRMessage *message = [[IRMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    NSString *URLStr = @"https://lh5.googleusercontent.com/nQn_fk9jILbWar1rGvY6LSh9s0zIyP5fWm23ZAmv-i0Wi4S2VjQWJquUlZkJw6A8B3_VvQrjVRY=w2033-h1154";
    [dataDic setObject:@1 forKey:@"from"];
    [dataDic setObject:[[NSDate date] description] forKey:@"strTime"];
    [dataDic setObject:@"Marcus" forKey:@"strName"];
    [dataDic setObject:URLStr forKey:@"strIcon"];
    
    [message setWithDict:dataDic];
    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    messageFrame.showTime = message.showDateLabel;
    [messageFrame setMessage:message];
    
    if (message.showDateLabel) {
        previousTime = dataDic[@"strTime"];
    }
    [self.dataSource addObject:messageFrame];
}

static NSString *previousTime = nil;

- (NSArray *)additems:(NSInteger)number
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (int i=0; i<number; i++) {
        
        IRMessageFrame *messageFrame = [[IRMessageFrame alloc]init];
        IRMessage *message = [[IRMessage alloc] init];
        NSDictionary *dataDic = [self getDic];
        
        [message setWithDict:dataDic];
        [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
        messageFrame.showTime = message.showDateLabel;
        [messageFrame setMessage:message];
        
        if (message.showDateLabel) {
            previousTime = dataDic[@"strTime"];
        }
        [result addObject:messageFrame];
    }
    return result;
}

static int dateNum = 10;

- (NSDictionary *)getDic
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int randomNum = arc4random()%2;
    switch (randomNum) {
        case 0:// text
            [dictionary setObject:[self randomString] forKey:@"strContent"];
            break;
        case 1:// picture
            [dictionary setObject:[UIImage imageNamed:@"haha.jpeg"] forKey:@"picture"];
            break;
            //            case 2:// audio
            //                [dictionary setObject:@"" forKey:@"voice"];
            //                [dictionary setObject:@"" forKey:@"strVoiceTime"];
            //                break;
        default:
            break;
    }
    NSString *URLStr = @"https://pbs.twimg.com/profile_images/433593115698417665/ihgmGPl4.jpeg";
    NSDate *date = [[NSDate date]dateByAddingTimeInterval:arc4random()%1000*(dateNum++) ];
    [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"from"];
    [dictionary setObject:[NSNumber numberWithInt:randomNum] forKey:@"type"];
    [dictionary setObject:[date description] forKey:@"strTime"];
    [dictionary setObject:@"Robin" forKey:@"strName"];
    [dictionary setObject:URLStr forKey:@"strIcon"];
    
    return dictionary;
}


- (NSString *)randomString {
    
    NSString *lorumIpsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non quam ac massa viverra semper. Maecenas mattis justo ac augue volutpat congue. Maecenas laoreet, nulla eu faucibus gravida, felis orci dictum risus, sed sodales sem eros eget risus. Morbi imperdiet sed diam et sodales. Vestibulum ut est id mauris ultrices gravida. Nulla malesuada metus ut erat malesuada, vitae ornare neque semper. Aenean a commodo justo, vel placerat odio";
    
    NSArray *lorumIpsumArray = [lorumIpsum componentsSeparatedByString:@" "];
    
    int r = arc4random() % [lorumIpsumArray count];
    r = MAX(3, r); // no less than 3 words
    NSArray *lorumIpsumRandom = [lorumIpsumArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, r)]];
    
    return [NSString stringWithFormat:@"%@!!", [lorumIpsumRandom componentsJoinedByString:@" "]];
}

@end