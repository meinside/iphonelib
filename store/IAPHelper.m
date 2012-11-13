//
//  IAPHelper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 4. 26.
//
//  last update: 12.11.13.
//

#import "IAPHelper.h"

#import "Logging.h"


@implementation IAPHelper

@synthesize delegate;
@synthesize productsRequest;
@synthesize paymentQueue;

static IAPHelper* _instance;

- (id)init
{
	if((self = [super init]))
	{
		self.paymentQueue = [SKPaymentQueue defaultQueue];
		[paymentQueue addTransactionObserver:self];
	}
	return self;
}

+ (IAPHelper*)sharedInstance
{
	if(!_instance)
	{
		_instance = [[IAPHelper alloc] init];
	}
	return _instance;
}

+ (void)disposeSharedInstance
{
	[_instance release];
	_instance = nil;
}

- (void)dealloc
{
	self.delegate = nil;
	[paymentQueue removeTransactionObserver:self];

	[productsRequest release];
	[paymentQueue release];

	[super dealloc];
}


#pragma mark -
#pragma mark request functions

+ (BOOL)canMakePayments
{
	return [SKPaymentQueue canMakePayments];
}

- (void)requestProductsWithIdentifiers:(NSSet*)identifiers
{
	@synchronized(self)
	{
		DebugLog(@"requesting products with identifiers: %@", identifiers);

		self.productsRequest = [[[SKProductsRequest alloc] initWithProductIdentifiers:identifiers] autorelease];
		self.productsRequest.delegate = self;
		[self.productsRequest start];
	}
}

- (void)purchaseProduct:(SKProduct*)product
{
	DebugLog(@"trying to purchase product: %@", product);

	[paymentQueue addPayment:[SKPayment paymentWithProduct:product]];
}

- (void)finishTransaction:(SKPaymentTransaction*)transaction
{
	DebugLog(@"finishing transaction: %@", transaction);
	
	[paymentQueue finishTransaction:transaction];
}

- (void)restoreCompletedPurchases
{
	DebugLog(@"trying to restore completed purchases");

	[paymentQueue restoreCompletedTransactions];
}


#pragma mark -
#pragma mark sk request delegate functions

- (void)requestDidFinish:(SKRequest *)request
{
	DebugLog(@"request did finish: %@", request);
	
	if([delegate respondsToSelector:@selector(requestDidFinish:)])
		[delegate requestDidFinish:request];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	DebugLog(@"request did fail with error: %@ / %@", request, error);
	
	if([delegate respondsToSelector:@selector(request:didFailWithError:)])
		[delegate request:request didFailWithError:error];
}


#pragma mark -
#pragma mark sk products request delegate functions

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	DebugLog(@"received products response: %@", response);

	[delegate receivedProductsResponse:response];
}


#pragma mark -
#pragma mark sk payment transaction observer delegate functions

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	DebugLog(@"updated transactions: %@", transactions);

	[delegate updatedTransactions:transactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
	DebugLog(@"removed transactions: %@", transactions);

	[delegate purchaseCompleted:transactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	DebugLog(@"restoring completed transactions failed: %@", error);

	[delegate restoreFailed:error];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	DebugLog(@"restored completed transactions: %@", queue);

	[delegate restoreCompleted:queue];
}

@end
