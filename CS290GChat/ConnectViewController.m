//
//  ViewController.m
//  CS290GChat
//
//  Created by Johan Henkens on 5/8/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import "ConnectViewController.h"
#import "ChatViewController.h"
#import <CS290GECC/CS290GECC.h>

@interface ConnectViewController ()

@end

@implementation ConnectViewController
@synthesize chatSession;

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
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
            NSLog(@"Chat peers was empty, setting to empty string");
            chat.peer = @"";
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    peerPicker = [[GKPeerPickerController alloc] init];
    peerPicker.delegate = self;
    peerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    chatPeers = [[NSMutableArray alloc] init];
    disconnectTriggeredBack = NO;
    [CSLog log];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connect:(id)sender {
    [peerPicker show];
}



- (void) viewWillDisappear:(BOOL)animated {
    if([self.navigationController.viewControllers indexOfObject:self]==NSNotFound){
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
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type{
	// Create a session with a unique session ID - displayName:nil = Takes the iPhone Name
	GKSession* session = [[GKSession alloc] initWithSessionID:@"com.johanhenkens.CS290GChat" displayName:nil sessionMode:GKSessionModePeer];
    return session;
}

// Tells us that the peer was connected
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session{
	
	// Get the session and assign it locally
    self.chatSession = session;
    session.delegate = self;
//    
//    //No need of the picker anymore
//	picker.delegate = nil;
    [picker dismiss];
}

#pragma mark -
#pragma mark GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
    NSLog(@"State changed to %d!",(int)state);
	if(state == GKPeerStateConnected){
		// Add the peer to the Array
		[chatPeers addObject:peerID];
        [session setDataReceiveHandler:self withContext:nil];
        [self performSegueWithIdentifier:@"connectedSegue" sender:self];
		// Used to acknowledge that we will be sending data
		
		
	} else if (state == GKPeerStateDisconnected){
        [chatPeers removeObject:peerID];
        // Any processing when a peer disconnects.
		NSString *str = [NSString stringWithFormat:@"%@ ended the connection!",[session displayNameForPeer:peerID]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //Go to the previous view.
        disconnectTriggeredBack = YES;
        [self.navigationController popViewControllerAnimated:YES];
        chatSession=nil;
    }
	
}

@end


