//
//  ViewController.m
//  CS290GChat
//
//  Created by Johan Henkens on 5/8/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "ConnectViewController.h"
#import "ChatViewController.h"

@interface ConnectViewController ()

@end

@implementation ConnectViewController
@synthesize chatSession;
@synthesize curve = __curve;
@synthesize haveReceivedPublicPoint = __haveReceivedPublicPoint;
@synthesize otherPeerIsReady = __otherPeerIsReady;
@synthesize isReady = __isReady;
@synthesize receivedPublicPoint = __receivedPublicPoint;

- (void) prepareForSegue:(UIStoryboardSegue *)segue
                  sender:(id)sender
{
    if([segue.identifier isEqualToString:@"connectedSegue"]){
        ChatViewController *chat = (ChatViewController *) segue.destinationViewController;
        chatSession.delegate=chat;
        chat.chatSession = self.chatSession;
        [chatSession setDataReceiveHandler:chat withContext:nil];
        if([chatPeers count] == 1){
            chat.peer = [chatPeers objectAtIndex:0];
        } else if ([chatPeers count] > 1){
            NSLog(@"Chat peers was larger than expected (%lu)",(unsigned long)[chatPeers count]);
        } else{
            NSLog(@"Chat peers was empty.");
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"View did load.");
	// Do any additional setup after loading the view, typically from a nib.
    peerPicker = [[GKPeerPickerController alloc] init];
    peerPicker.delegate = self;
    peerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    chatPeers = [[NSMutableArray alloc] init];
    [self connectingLabel].hidden=YES;
    [self setHaveReceivedPublicPoint:NO];
    [self setOtherPeerIsReady:NO];
    [self setIsReady:NO];
    [self setReceivedPublicPoint:[[BigPoint alloc]init]];
    [self setCurve:[[ECC alloc] init]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connect:(id)sender
{
    [peerPicker show];
}

- (void) checkEncryption:(NSTimer *) timer
{
    NSLog(@"%@: checkEncryption",([self class]));

    if([self isReady] && [self otherPeerIsReady])
    {
        [timer invalidate];
        [self performSegueWithIdentifier:@"connectedSegue" sender:self];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self connectButton].hidden=NO;
    [self connectingLabel].hidden=YES;
    if([self.navigationController.viewControllers indexOfObject:self]==NSNotFound)
    {
//        This code is broken currently. Figure out a new way to do disconnects
//        TODO: Do Disconnects. Maybe send our own message to tell the client to disconnect, and then handle others as fallback?
//        NSLog(@"Found back button press.");
//        if(disconnectTriggeredBack == NO){
//            //Disconnect Peers when the disconnect button is pressed!
//            NSLog(@"Button was manually pressed, begin cleanup/disconnect.");
//            [self.chatSession disconnectFromAllPeers];
//            self.chatSession.available=NO;
//            [self.chatSession setDataReceiveHandler:nil withContext:nil];
//            self.chatSession.delegate=nil;
//            self.chatSession = nil;
//        } else{
//            NSLog(@"Button was programatically pressed, do nothing.");
//        }
//        disconnectTriggeredBack = NO;
    }
    [super viewWillDisappear:animated];
}
// Code skeletons from http://vivianaranha.com/apple-gamekit-bluetooth-integration-tutorial/
#pragma mark -
#pragma mark GKPeerPickerControllerDelegate

// This creates a unique Connection Type for this particular applictaion
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker
           sessionForConnectionType:(GKPeerPickerConnectionType)type
{
	// Create a session with a unique session ID - displayName:nil = Takes the iPhone Name
	GKSession* session = [[GKSession alloc] initWithSessionID:@"com.johanhenkens.CS290GChat" displayName:nil sessionMode:GKSessionModePeer];
    return session;
}

- (void)sendPointDataAfterWait
{
    NSLog(@"%@: sendPointDataAfterWait: sending...",NSStringFromClass([self class]));
    [NSThread sleepForTimeInterval:0.5];
    NSError* error=nil;
    NSData* data =[[[self curve] publicKey] getMpiNSData] ;
    [[self chatSession] sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
    if(error==nil)
    {
        NSLog(@"%@: sendPointDataAfterWait: sent!",NSStringFromClass([self class]));
    } else
    {
        NSLog(@"%@: sendPointDataAfterWait: error occured! %@",NSStringFromClass([self class]),[error localizedDescription]);
    }
    
}

// Tells us that the peer was connected
- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *)session
{
    NSLog(@"%@: didPeerConnect: peer %@ available (%@)",NSStringFromClass([self class]),[session displayNameForPeer:peerID],peerID);
	// Get the session and assign it locally
    self.chatSession = session;
    session.delegate = self;
    
//  Dismiss the picker to hide it from the view.
    [picker dismiss];
//    [self performSelectorInBackground:@selector(sendPointDataAfterWait) withObject:nil];
    [self performSelectorInBackground:@selector(sendPointDataAfterWait) withObject:nil];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkEncryption:) userInfo:nil repeats:YES];

}

// Function to receive data when sent from peer
- (void)receiveData:(NSData *)data
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context
{
    NSLog(@"%@: receieData",NSStringFromClass([self class]));
    
    if(![self haveReceivedPublicPoint])
    {
        [self setHaveReceivedPublicPoint:YES];
        [[self receivedPublicPoint] setToMpiNSData:data];
        [[self curve] makeSharedSecretFromPublicPoint:[self receivedPublicPoint]];
        //Send empty data to tell peer we are ready.
        //TODO: Make this use the encrypted channel to say we are ready!
        NSString* str = @"I am ready!";
        [session sendDataToAllPeers:[str dataUsingEncoding:NSASCIIStringEncoding]
                       withDataMode:GKSendDataReliable error:nil];
        [self setIsReady:YES];
        NSLog(@"Am now ready! Shared secret: %@",[[self curve] sharedSecret]);
    }
    else if(![self otherPeerIsReady])
    {
        [self setOtherPeerIsReady:YES];
    }
}

#pragma mark -
#pragma mark GKSessionDelegate

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
            [chatPeers addObject:peerID];
            [session setDataReceiveHandler:self withContext:nil];
            [self connectButton].hidden = YES;
            [self connectingLabel].hidden = NO;
            break;
        case GKPeerStateDisconnected:
            NSLog(@"%@: didStateChange: peer %@ disconnected (%@)",NSStringFromClass([self class]),[session displayNameForPeer:peerID],peerID);
            break;
    }
}

@end


