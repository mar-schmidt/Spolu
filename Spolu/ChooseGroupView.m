//
//  ChooseGroupView.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-07.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "ChooseGroupView.h"
#import "ImageLabelView.h"
#import "IRGroup.h"
#import "AFHTTPRequestOperationManager.h"

static const CGFloat ChooseGroupViewImageLabelWidth = 42.f;

@interface ChooseGroupView ()
@property (nonatomic, strong) UIView *informationView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation ChooseGroupView

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
                       group:(IRGroup *)group
                      options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame options:options];
    if (self) {
        _group = group;

        // ORIGINAL self.imageView.image = imageV.image;
        self.imageView.image = group.downloadedImage;
        /*
        if (![self isDownloading:[NSURL URLWithString:group.imageUrl]]) {
            [self downloadImageWithURL:[NSURL URLWithString:group.imageUrl]
                              forGroup:group
                       completionBlock:^(BOOL succeeded, UIImage *image) {
                           if (succeeded) {
                               // cache the image for use later (when scrolling up)
                               group.downloadedImage = image;
                               self.imageView.image = group.downloadedImage;
                               /
                               // Animate away the progressbar nicely
                               CATransition *animation = [CATransition animation];
                               animation.type = kCATransitionFade;
                               animation.duration = 1;
                               [cell.progressBar.layer addAnimation:animation forKey:nil];
                               cell.progressBar.hidden = YES;
                                */
        /*
                           } else {
                               /
                               // Animate away the progressbar and in with errormessage nicely
                               CATransition *animation = [CATransition animation];
                               animation.type = kCATransitionFade;
                               animation.duration = 1;
                               [cell.progressBar.layer addAnimation:animation forKey:nil];
                               [cell.errorMessage.layer addAnimation:animation forKey:nil];
                               cell.errorMessage.hidden = NO;
                               cell.progressBar.hidden = YES;
                                */
        /*
                           }
                       }];
        }
         */
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.autoresizingMask = self.autoresizingMask;
        
        [self constructInformationView];
    }
    return self;
}

- (BOOL)isDownloading:(NSURL *)url
{
    if (!currentDownloads) {
        currentDownloads = [[NSMutableArray alloc] init];
    }
    if ([currentDownloads containsObject:url]) {
        return YES;
    } else return NO;
}

- (void)downloadImageWithURL:(NSURL *)url forGroup:(IRGroup *)group completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    // Add url to currentDownloading array so we can keep track of that and dont trigger multiple downloads on same url
    [currentDownloads addObject:url];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:[NSString stringWithFormat:@"%@", url]
                                                                                parameters:nil
                                                                                     error:nil];
    
    AFHTTPRequestOperation *requestOperation = [manager HTTPRequestOperationWithRequest:request
                                                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                    UIImage *image = responseObject;
                                                                                    completionBlock(YES, image);
                                                                                    // Remove from currentDownloads, the cache will return correct image
                                                                                    [currentDownloads removeObject:url];
                                                                                }
                                                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                    NSLog(@"Error: %@", error);
                                                                                    completionBlock(NO, nil);
                                                                                    [requestOperation cancel];
                                                                                    // Remove from currentDownloads due to failure in current download
                                                                                    [currentDownloads removeObject:url];
                                                                                }];
    
    [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        double percentDone = (double)totalBytesRead / (double)totalBytesExpectedToRead;
        NSLog(@"progress updated(percentDone) for profileImage : %f", percentDone);
        /*if (type == RecipeImage) {
            NSLog(@"progress updated(percentDone) for section %ld : %f", (long)indexPath.section, percentDone);
            [cell.progressBar setProgress:percentDone animated:YES];
        }
        else if (type == ProfileImage) {
            NSLog(@"progress updated(percentDone) for profileImage : %f", percentDone);
            [roundProgressView setProgress:percentDone animated:YES];
            if (percentDone == 1) {
                // Animate away the tintcolor of roundprogressview
                CATransition *animation = [CATransition animation];
                animation.type = kCATransitionFade;
                animation.duration = 0.5;
                [roundProgressView.layer addAnimation:animation forKey:nil];
                roundProgressView.tintColor = [UIColor whiteColor];
            }
        }
         */
    }];
    [requestOperation start];
}

#pragma mark - Internal Methods

- (void)constructInformationView {
    CGFloat bottomHeight = 00.f;
    CGRect bottomFrame = CGRectMake(0,
                                    CGRectGetHeight(self.bounds) - bottomHeight,
                                    CGRectGetWidth(self.bounds),
                                    bottomHeight);
    _informationView = [[UIView alloc] initWithFrame:bottomFrame];
    _informationView.backgroundColor = [UIColor whiteColor];
    _informationView.clipsToBounds = YES;
    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_informationView];
    
    /*
     [self constructNameLabel];
     [self constructCameraImageLabelView];
     [self constructInterestsImageLabelView];
     [self constructFriendsImageLabelView];
     */
}
/*
 - (void)constructNameLabel {
 CGFloat leftPadding = 12.f;
 CGFloat topPadding = 17.f;
 CGRect frame = CGRectMake(leftPadding,
 topPadding,
 floorf(CGRectGetWidth(_informationView.frame)/2),
 CGRectGetHeight(_informationView.frame) - topPadding);
 _nameLabel = [[UILabel alloc] initWithFrame:frame];
 _nameLabel.text = [NSString stringWithFormat:@"%@, %@", _person.name, @(_person.age)];
 [_informationView addSubview:_nameLabel];
 }
 
 - (void)constructCameraImageLabelView {
 CGFloat rightPadding = 10.f;
 UIImage *image = [UIImage imageNamed:@"camera"];
 _cameraImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetWidth(_informationView.bounds) - rightPadding
 image:image
 text:[@(_person.numberOfPhotos) stringValue]];
 [_informationView addSubview:_cameraImageLabelView];
 }
 
 - (void)constructInterestsImageLabelView {
 UIImage *image = [UIImage imageNamed:@"book"];
 _interestsImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_cameraImageLabelView.frame)
 image:image
 text:[@(_person.numberOfPhotos) stringValue]];
 [_informationView addSubview:_interestsImageLabelView];
 }
 
 - (void)constructFriendsImageLabelView {
 UIImage *image = [UIImage imageNamed:@"group"];
 _friendsImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_interestsImageLabelView.frame)
 image:image
 text:[@(_person.numberOfSharedFriends) stringValue]];
 [_informationView addSubview:_friendsImageLabelView];
 }
*/
- (ImageLabelView *)buildImageLabelViewLeftOf:(CGFloat)x image:(UIImage *)image text:(NSString *)text {
    CGRect frame = CGRectMake(x - ChooseGroupViewImageLabelWidth,
                              0,
                              ChooseGroupViewImageLabelWidth,
                              CGRectGetHeight(_informationView.bounds));
    ImageLabelView *view = [[ImageLabelView alloc] initWithFrame:frame
                                                           image:image
                                                            text:text];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return view;
}

@end
