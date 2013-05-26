//
//  ChatViewController.m
//  CS290GChat
//
//  Created by Johan Henkens on 5/9/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController
@synthesize chatSession;
@synthesize peer;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate=self;
    self.dataSource=self;
    self.title = [chatSession displayNameForPeer:peer];
    self.messages = [[NSMutableArray alloc] init];
    self.timestamps = [[NSMutableArray alloc] init];
    self.sender = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view delegate

- (void)sendPressed:(UIButton *)sender
           withText:(NSString *)text
{
    [self.messages addObject:text];
    [self.timestamps addObject:[NSDate date]];
    [self.sender addObject:[NSNumber numberWithBool:NO]];
    [JSMessageSoundEffect playMessageSentSound];
    [chatSession sendDataToAllPeers:[text dataUsingEncoding:NSASCIIStringEncoding] withDataMode:GKSendDataReliable error:nil];
    [self finishSend];
}

- (JSMessagesViewTimestampPolicy)timestampPolicyForMessagesView
{
    return JSMessagesViewTimestampPolicyAll;
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([[self.sender objectAtIndex:indexPath.row] boolValue]) ? JSBubbleMessageStyleIncomingDefault : JSBubbleMessageStyleOutgoingDefault;
}

-(BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self shouldHaveTimestampForRowAtIndexPath:indexPath];
}

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}
- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.timestamps objectAtIndex:indexPath.row];
}

#pragma mark - GKPeerPickerControllerDelegate
// Function to receive data when sent from peer
- (void)receiveData:(NSData *)data
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context
{
    NSLog(@"Received data in ChatView");
	//Convert received NSData to NSString to display
   	NSString *whatDidIget = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [self.messages addObject:whatDidIget];
    [self.timestamps addObject:[NSDate date]];
    [self.sender addObject:[NSNumber numberWithBool:YES]];
    [JSMessageSoundEffect playMessageReceivedSound];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

#pragma mark - GKSessionDelegate
- (void)session:(GKSession *)session
           peer:(NSString *)peerID 
 didChangeState:(GKPeerConnectionState)state
{
    switch (state){
    case GKPeerStateAvailable:
        NSLog(@"%@: didStateChange: peer %@ available (%@)",NSStringFromClass([self class]),[session displayNameForPeer:peerID],peerID);
        break;
    case GKPeerStateUnavailable:
        NSLog(@"%@: didStateChange: peer %@ unavailable (%@)",NSStringFromClass([self class]),[session displayNameForPeer:peerID],peerID);
        break;
    case GKPeerStateConnecting:
        NSLog(@"%@: didStateChange: peer %@ connecting (%@)",NSStringFromClass([self class]),[session displayNameForPeer:peerID],peerID);
        break;
    case GKPeerStateConnected:
        NSLog(@"%@: didStateChange: peer %@ connected (%@)",NSStringFromClass([self class]),[session displayNameForPeer:peerID],peerID);
        break;
    case GKPeerStateDisconnected:
        NSLog(@"%@: didStateChange: peer %@ disconnected (%@)",NSStringFromClass([self class]),[session displayNameForPeer:peerID],peerID);
        break;
    }
}



@end


