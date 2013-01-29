//
//  AddBumpFormViewController.m
//  BachesBA
//
//  Created by Nicolas Ameghino on 29/01/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import "AddBumpFormViewController.h"
#import "NAJSONRequestOperation.h"

@interface AddBumpFormViewController ()

@end

@implementation AddBumpFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) submitForm:(id) sender {
    NSMutableDictionary *formContent = [NSMutableDictionary new];
    [self.root fetchValueIntoObject:formContent];
    

    formContent[@"frm_barrio_id"] = [BachesBAClient sharedInstance].neighbourhoods[formContent[@"frm_barrio"]];
    
    QRadioElement *radioElement = (QRadioElement*)[self.root elementWithKey:@"frm_tipo"];
    id typeKey = [radioElement items][[formContent[@"frm_tipo"] integerValue]];
    formContent[@"frm_tipo"] = [BachesBAClient sharedInstance].holeTypes[typeKey];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    formContent[@"frm_fecha"] = [df stringFromDate:formContent[@"frm_fecha"]];
    NSLog(@"%@", formContent);
    
    [self geocode:formContent];
}

-(void) postForm:(NSDictionary*) form {
    BachesBAClient *client = [BachesBAClient sharedInstance];
    NSMutableURLRequest *request = [client requestWithMethod:@"GET"
                                                        path:@"hecho.php"
                                                  parameters:form];
    NSLog(@"Target URL: %@", [request.URL absoluteString]);
    AFJSONRequestOperation *operation = [NAJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            NSLog(@"Success posting. Data as follows:\n%@", JSON);
                                                                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"Post failed: %@", [error localizedDescription]);
                                                                                        }];
    [operation start];
}


-(void) geocode:(NSMutableDictionary*) form {
    NSString *geocodingTarget = [NSString stringWithFormat:@"%@ %@, %@, CABA, Argentina", form[@"frm_calle"], form[@"frm_nro"], form[@"frm_barrio"]];
    NSLog(@"geo target: %@", geocodingTarget);
    NSURL *targetURL = [NSURL URLWithString:@"http://maps.googleapis.com/maps/api/geocode/"];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:targetURL];
    NSURLRequest *request = [client requestWithMethod:@"GET"
                                                 path:@"json"
                                           parameters:@{
                                                @"address": geocodingTarget,
                                                @"sensor": @"false"
                             }];
    NSLog(@"%@", [request.URL absoluteString]);
    AFJSONRequestOperation *operation = [NAJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            @try {
                                                                                                NSDictionary *result = JSON[@"results"][0];
                                                                                                NSDictionary *coordinates = result[@"geometry"][@"location"];
                                                                                                NSLog(@"Coordinates: %@", coordinates);
                                                                                                
                                                                                                form[@"frm_lat"] = coordinates[@"lat"];
                                                                                                form[@"frm_lng"] = coordinates[@"lng"];
                                                                                                form[@"frm_direcciongoogle"] = result[@"formatted_address"];
                                                                                                form[@"frm_viewport"] = result[@"geometry"][@"viewport"];
                                                                                                form[@"frm_comentario"] = @"Cargado desde BachesBA para iOS.";
                                                                                                NSLog(@"new form\n%@", form);
                                                                                                
                                                                                                [self postForm:form];
                                                                                            }
                                                                                            @catch (NSException *exception) {
                                                                                                NSLog(@"Something went wrong...");
                                                                                            }
                                                                                            
                                                                                            
                                         
                                                                                            
                                                                                            
                                                                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"Geocoding request FAILED: %@", [error localizedDescription]);
                                                                                        }];
    [operation start];
    
}

+(QRootElement*) buildForm {
    QRootElement *root = [[QRootElement alloc] init];
    root.title = @"Agregar bache";
    root.controllerName = NSStringFromClass(self);
    
    root.grouped = YES;
    
    /** Formulario web **/
    /*
     barrio - (frm_barrio_id / frm_barrio) - autocomplete: http://buenosairesbache.com/app/barrios.php
     direccion - (frm_calle)
     altura - (frm_nro)
     tamanio - (frm_tipo) - dropdown - http://buenosairesbache.com/app/
     fecha d/m/a - (frm_fecha)
     submit - target: http://buenosairesbache.com/app/hecho.php?
    */
    
    QAutoEntryElement *neighbourhoodEntryElement = [[QAutoEntryElement alloc] initWithTitle:@"Barrio" Value:nil];
    neighbourhoodEntryElement.autoCompleteValues = [[BachesBAClient sharedInstance].neighbourhoods allKeys];
    neighbourhoodEntryElement.autoCompleteColor = [UIColor blueColor];
    neighbourhoodEntryElement.key = @"frm_barrio";
    
    QEntryElement *streetNameEntryElement = [[QEntryElement alloc] initWithTitle:@"Calle" Value:nil];
    streetNameEntryElement.key = @"frm_calle";
    
    QEntryElement *streetNumberElement = [[QEntryElement alloc] initWithTitle:@"Numero" Value:nil];
    streetNumberElement.key = @"frm_nro";
    
    QRadioElement *bumpSizeRadioElement = [[QRadioElement alloc] initWithItems:[[BachesBAClient sharedInstance].holeTypes allKeys]
                                                                      selected:0
                                                                         title:@"Tamaño"];
    bumpSizeRadioElement.key = @"frm_tipo";
    
    QDateTimeInlineElement *dateTimeInlineElement = [[QDateTimeInlineElement alloc] initWithDate:[NSDate date]];
    dateTimeInlineElement.title = @"Fecha";
    dateTimeInlineElement.key = @"frm_fecha";
    dateTimeInlineElement.mode = UIDatePickerModeDate;
    
    QSection *section = [[QSection alloc] init];
    
    [section addElement:neighbourhoodEntryElement];
    [section addElement:streetNameEntryElement];
    [section addElement:streetNumberElement];
    [section addElement:bumpSizeRadioElement];
    [section addElement:dateTimeInlineElement];
    
    QSection *commentsSection = [[QSection alloc] initWithTitle:@"Comentarios"];
    
    [root addSection:commentsSection];
    
    QEntryElement *nameEntryElement = [[QEntryElement alloc] initWithTitle:@"Nombre" Value:nil];
    nameEntryElement.key = @"frm_nombre";
    
    QButtonElement *submitButtonElement = [[QButtonElement alloc] initWithTitle:@"Enviar" Value:nil];
    submitButtonElement.enabled = YES;
    submitButtonElement.controllerAction = @"submitForm:";
    
    
    QSection *submitButtonSection = [[QSection alloc] init];
    [submitButtonSection addElement:nameEntryElement];
    [submitButtonSection addElement:submitButtonElement];
    
    [root addSection: section];
    [root addSection: submitButtonSection];
    
    return root;
}

@end
