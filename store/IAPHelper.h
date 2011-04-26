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
//  IAPHelper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 4. 26.
//
//  last update: 11.04.26.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>	//needs: 'StoreKit.framework'


@protocol IAPHelperDelegate;

@interface IAPHelper : NSObject <SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver> {

	id<IAPHelperDelegate> delegate;

	SKProductsRequest* productsRequest;
	SKPaymentQueue* paymentQueue;
}

+ (IAPHelper*)sharedInstance;
+ (void)disposeSharedInstance;

+ (BOOL)canMakePayments;

//identifiers: NSSet of NSString objects
- (void)requestProductsWithIdentifiers:(NSSet*)identifiers;

- (void)purchaseProduct:(SKProduct*)product;
- (void)purchaseProductWithIdentifier:(NSString*)identifier;

- (void)finishTransaction:(SKPaymentTransaction*)transaction;

- (void)restoreCompletedPurchases;


@property (assign) id<IAPHelperDelegate> delegate;
@property (retain) SKProductsRequest* productsRequest;
@property (retain) SKPaymentQueue* paymentQueue;

@end


@protocol IAPHelperDelegate <NSObject>

@required

- (void)receivedProductsResponse:(SKProductsResponse*)response;

- (void)purchaseCompleted:(NSArray*)transactions;

/**
 * If given trasaction's state is equal to 'SKPaymentTransactionStatePurchased':
 * 
 * 1. should enable/download feature for this transaction.
 * 2. after that, should call IAPHelper's 'finishTransaction:' function 
 * 
 */
- (void)updatedTransactions:(NSArray*)transactions;

- (void)restoreCompleted:(SKPaymentQueue*)queue;
- (void)restoreFailed:(NSError*)error;

@optional

- (void)requestDidFinish:(SKRequest*)request;
- (void)request:(SKRequest*)request didFailWithError:(NSError*)error;

@end
