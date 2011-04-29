/*
 Copyright (c) 2010, Sungjin Han <meinside@gmail.com>
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
  * Neither the name of meinside nor the names of its contributors may be
    used to endorse or promote products derived from this software without
    specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */
//
//  IAPHelper.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 4. 26.
//
//  last update: 11.04.29.
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


#pragma -
#pragma request functions

+ (BOOL)canMakePayments
{
	return [SKPaymentQueue canMakePayments];
}

- (void)requestProductsWithIdentifiers:(NSSet*)identifiers
{
	@synchronized(self)
	{
		DebugLog(@"requesting products with identifiers: %@", identifiers);

		self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
		self.productsRequest.delegate = self;
		[self.productsRequest start];
	}
}

- (void)purchaseProduct:(SKProduct*)product
{
	DebugLog(@"trying to purchase product: %@", product);

	[paymentQueue addPayment:[SKPayment paymentWithProduct:product]];
}

- (void)purchaseProductWithIdentifier:(NSString*)identifier
{
	DebugLog(@"trying to purchase product with identifier: %@", identifier);

	[paymentQueue addPayment:[SKPayment paymentWithProductIdentifier:identifier]];
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


#pragma -
#pragma sk request delegate functions

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


#pragma -
#pragma sk products request delegate functions

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	DebugLog(@"received products response: %@", response);

	[delegate receivedProductsResponse:response];
}


#pragma -
#pragma sk payment transaction observer delegate functions

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
