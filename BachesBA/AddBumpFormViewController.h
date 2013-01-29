//
//  AddBumpFormViewController.h
//  BachesBA
//
//  Created by Nicolas Ameghino on 29/01/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import <QuickDialog/QuickDialog.h>
#import <AFNetworking/AFNetworking.h>

#import "BachesBAClient.h"

@interface AddBumpFormViewController : QuickDialogController
+(QRootElement*) buildForm;
@end
