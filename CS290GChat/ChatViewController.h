//
//  ChatViewController.h
//  CS290GChat
//
//  Created by Johan Henkens on 5/9/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "JSMessagesViewController.h"
#import <GameKit/GameKit.h>
#import <CS290GECC/CS290GECC.h>
#import <RNCryptor/RNEncryptor.h>
#import <RNCryptor/RNDecryptor.h>


@interface ChatViewController : JSMessagesViewController <GKSessionDelegate,JSMessagesViewDelegate,JSMessagesViewDataSource>{
    GKSession *chatSession;
    NSString *peer;
    
}
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *sender;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (retain) GKSession *chatSession;
@property (retain) NSString *peer;
@property (nonatomic, strong) NSString *password;

@end
