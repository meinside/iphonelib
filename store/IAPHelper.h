//
//  IAPHelper.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 4. 26.
//
//  last update: 12.11.13.
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
 * If given trasaction's state is equal to 'SKPaymentTransactionStatePurchased' or 'SKPaymentTransactionStateRestored':
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
