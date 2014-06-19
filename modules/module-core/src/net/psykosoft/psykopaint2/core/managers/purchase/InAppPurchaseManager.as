package net.psykosoft.psykopaint2.core.managers.purchase
{
	import com.milkmangames.nativeextensions.ios.StoreKit;
	import com.milkmangames.nativeextensions.ios.StoreKitProduct;
	import com.milkmangames.nativeextensions.ios.events.StoreKitErrorEvent;
	import com.milkmangames.nativeextensions.ios.events.StoreKitEvent;
	
	import flash.net.SharedObject;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.UserConfigModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyProductPriceSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPurchaseStatusSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateMessagePopUpSignal;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

	public class InAppPurchaseManager
	{
		
		public static const STATUS_PURCHASE_COMPLETE:int = 0;
		public static const STATUS_PURCHASE_FAILED:int = 1;
		public static const STATUS_PURCHASE_CANCELLED:int = 2;
		public static const STATUS_PURCHASE_RESTORED:int = 3;
		public static const STATUS_PURCHASE_RESTORE_FAILED:int = 4;
		public static const STATUS_PURCHASE_NOT_REQUIRED:int = 5;
		public static const STATUS_STORE_UNAVAILABLE:int = 6;
		public static const STATUS_STORE_DISABLED:int = 7;
		public static const STATUS_STORE_PRODUCTS_AVAILABLE:int = 8;
		public static const STATUS_STORE_PRODUCTS_UNAVAILABLE:int = 9;
		
		
		/** Sample Product IDs, must match iTunes Connect Items */
		//public static const FULL_UPGRADE_PRODUCT_ID:String="com.psykopaint.ipad.fullVersionUpgrade";

		
		public static const PRODUCT_ID_FREE:String="com.psykopaint.app.free";
		
		public static const PRODUCT_ID_BRUSHKIT1:String="com.psykopaint.app.brushkit1";
		public static const PRODUCT_ID_WATERCOLOR_BRUSH_1:String="com.psykopaint.app.watercolorbrush1";
		public static const PRODUCT_ID_BRISTLE_BRUSH_1:String="com.psykopaint.app.bristlebrush1";
		public static const PRODUCT_ID_PAINTGUN_BRUSH_1:String="com.psykopaint.app.paintgunbrush1";
		public static const PRODUCT_ID_PENCIL_BRUSH_1:String="com.psykopaint.app.pencilbrush1";
		
		//potential future additions: 
		public static const PRODUCT_ID_BRUSHKIT2:String="com.psykopaint.app.brushkit2";
		public static const PRODUCT_ID_COSMETICS_BRUSH_1:String="com.psykopaint.app.cosmeticsbrush1";
		
		
		private static const productIdList:Vector.<String>= Vector.<String>(
			[PRODUCT_ID_BRUSHKIT1,
			PRODUCT_ID_WATERCOLOR_BRUSH_1,
			PRODUCT_ID_BRISTLE_BRUSH_1,
			PRODUCT_ID_PAINTGUN_BRUSH_1,
			PRODUCT_ID_PENCIL_BRUSH_1
			]);
		
		public static const packages:Vector.<String>= Vector.<String>(
			[PRODUCT_ID_BRUSHKIT1]);
		
		public static function isBrushPackage( productID:String ):Boolean
		{
			return ( packages.indexOf(productID) > -1 );
			
		}
	
		
		/** Shared Object.  Used in this example to remember what we've bought. */
		private var sharedObject:SharedObject;
		
		//private var initialized:Boolean = false;
		
		[Inject]
		public var notifyPurchaseStatusSignal:NotifyPurchaseStatusSignal
		
		[Inject]
		public var notifyProductPriceSignal:NotifyProductPriceSignal
		
		
		[Inject]
		public var userConfigModel:UserConfigModel
		
		private var availableProducts:Vector.<StoreKitProduct>;
		
		public function InAppPurchaseManager()
		{
		}
		
		[PostConstruct]
		public function init() : void
		{
			// initialize a sharedobject that's holding our inventory.
			initSharedObject();
			
			//initialized = true;
			if (!StoreKit.isSupported())
			{
				trace("InAppPurchaseManager: Store Kit iOS purchases is not supported on this platform.");
				notifyPurchaseStatusSignal.dispatch(null,STATUS_STORE_UNAVAILABLE);
				return;
			}
			
			trace("InAppPurchaseManager: initializing StoreKit..");	
			
			StoreKit.create();
			
			trace("InAppPurchaseManager: StoreKit Initialized.");
			
			// make sure that purchases will actually work on this device before continuing!
			// (for example, parental controls may be preventing them.)
			if (!StoreKit.storeKit.isStoreKitAvailable())
			{
				notifyPurchaseStatusSignal.dispatch(null,STATUS_STORE_DISABLED);
				trace("InAppPurchaseManager: Store is disable on this device.");
				return;
			}
			
			// add listeners here
			StoreKit.storeKit.addEventListener(StoreKitEvent.PRODUCT_DETAILS_LOADED,onProductsLoaded);
			StoreKit.storeKit.addEventListener(StoreKitEvent.PURCHASE_SUCCEEDED,onPurchaseSuccess);
			StoreKit.storeKit.addEventListener(StoreKitEvent.PURCHASE_CANCELLED,onPurchaseUserCancelled);
			StoreKit.storeKit.addEventListener(StoreKitEvent.TRANSACTIONS_RESTORED, onTransactionsRestored);
			
			// adding error events. always listen for these to avoid your program failing.
			StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PRODUCT_DETAILS_FAILED,onProductDetailsFailed);
			StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PURCHASE_FAILED,onPurchaseFailed);
			StoreKit.storeKit.addEventListener(StoreKitErrorEvent.TRANSACTION_RESTORE_FAILED, onTransactionRestoreFailed);
			
			
			
			// the first thing to do is to supply a list of product ids you want to display,
			// and Apple's server will respond with a list of their details (titles, price, etc)
			// assuming the ids you pass in are valid.  Even if you don't need to use this 
			// information, you should make the details request before doing a purchase.
			
			// the list of ids is passed in as an as3 vector (typed Array.)
			
			
			
			// when this is done, we'll get a PRODUCT_DETAILS_LOADED or PRODUCT_DETAILS_FAILED event and go on from there...
			trace("InAppPurchaseManager: Loading product details...");
			StoreKit.storeKit.loadProductDetails(productIdList);	
			
		}
		
		/** Creates a SharedObject that we use in this example for remembering what you've already bought */
		private function initSharedObject():void
		{
			// initialize the saved state.  this is a very simple example implementation
			// and you probably want a more robust one in a real application.  you may
			// also consider obfuscating the data, and/or using an SQL database isntead
			// of a shared object.
			this.sharedObject=SharedObject.getLocal("myPurchases");
			var inventory:Object;
			
			// check if the application has been loaded before.  if not, create a store of our purchases in the sharedobject.
			if (sharedObject.data["inventory"]==null)
			{			
				inventory= sharedObject.data["inventory"] = {}
			} else {
				if ( !CoreSettings.RUNNING_ON_iPAD)  
				{
					sharedObject.data["inventory"] = {}
					sharedObject.flush();
				}
				inventory=sharedObject.data["inventory"];
				/*
				if( inventory[PRODUCT_ID_BRUSHKIT1]=="purchased")
				{
					userConfigModel.userConfig.hasBrushKit1 = true;
				}
				*/
			}
			userConfigModel.userConfig.setInventory(inventory);
			
			//updateInventoryMessage();
			
		}
		
		
		
		/** Example of how to purchase a product */
		public function purchaseProduct( productID:String ):void
		{
			
			
			if (!StoreKit.isSupported())
			{
				notifyPurchaseStatusSignal.dispatch(productID,STATUS_STORE_UNAVAILABLE);
				return;
			}
			
			// for this to work, you must have added the value of LEVELPACK_PRODUCT_ID in the iTunes Connect website
			trace("InAppPurchaseManager: start purchase of non-consumable '"+productID+"'...");
			
			// we won't let you purchase it if its already in your inventory!
			var inventory:Object=sharedObject.data["inventory"];
			if (inventory[productID]!=null)
			{
				notifyPurchaseStatusSignal.dispatch(productID,STATUS_PURCHASE_NOT_REQUIRED);
				trace("InAppPurchaseManager: You already have bought "+productID+"!");
				return;
			}
			
			StoreKit.storeKit.purchaseProduct(productID);
			
		}
		
		/** Example of how to restore transactions */
		public function restoreTransactions():void
		{
			
			// apple reccommends you provide a button in your ui to restore purchases,
			// for users who mightve uninstalled then reinstalled your application, etc.
			trace("InAppPurchaseManager: requesting transaction restore...");
			StoreKit.storeKit.restoreTransactions();
		}
		
	
		//
		// Events
		//	
		
		/** Called when details about available purchases has loaded */
		private function onProductsLoaded(e:StoreKitEvent):void
		{
			trace("InAppPurchaseManager: products loaded.");
			availableProducts = e.validProducts;
			for each(var product:StoreKitProduct in e.validProducts)
			{
				trace("ID: "+product.productId);
				trace("Title: "+product.title);
				trace("Description: "+product.description);
				trace("String Price: "+product.localizedPrice);
				trace("Price: "+product.price);
				//TODO: right now we only have one product so this is dirty but should work:
				notifyProductPriceSignal.dispatch(product);
			}
			trace("Loaded "+e.validProducts.length+" Products.");
			
			// if any of the product ids we tried to pass in were not found on the server,
			// we won't be able to by them so something is wrong.
			if (e.invalidProductIds.length>0)
			{
				trace("InAppPurchaseManager: these products not valid:"+e.invalidProductIds.join(","));
				return;
			}
			
			notifyPurchaseStatusSignal.dispatch(null,STATUS_STORE_PRODUCTS_AVAILABLE);
			
			//showFullUI();
			trace("InAppPurchaseManager: Ready! (hosted content supported?) "+StoreKit.storeKit.isHostedContentAvailable());
		}
		
		/** Called when product details failed to load */
		private function onProductDetailsFailed(e:StoreKitErrorEvent):void
		{
			notifyPurchaseStatusSignal.dispatch(null,STATUS_STORE_PRODUCTS_UNAVAILABLE);
			
			trace("InAppPurchaseManager: ERR loading products:"+e.text);
		}
		
		/** Called when an item is successfully purchased */
		private function onPurchaseSuccess(e:StoreKitEvent):void
		{
			trace("InAppPurchaseManager: Successful purchase of '"+e.productId+"'");
			
			// update our sharedobject with the state of this inventory item.
			// this is just an example to make the process clear.  you will
			// want to make your own inventory manager class to handle these
			// types of things.
			var inventory:Object=sharedObject.data["inventory"];
			inventory[e.productId]="purchased";
			
			// save state!
			sharedObject.flush();
			userConfigModel.userConfig.setInventory(inventory);
			
			notifyPurchaseStatusSignal.dispatch(e.productId,STATUS_PURCHASE_COMPLETE);
			
			
		}
		
		/** A purchase has failed */
		private function onPurchaseFailed(e:StoreKitErrorEvent):void
		{
			trace("InAppPurchaseManager: FAILED purchase="+e.productId+",t="+e.transactionId+",o="+e.originalTransactionId);
			notifyPurchaseStatusSignal.dispatch(e.productId,STATUS_PURCHASE_FAILED);
			
		}
		
		/** A purchase was cancelled */
		private function onPurchaseUserCancelled(e:StoreKitEvent):void
		{
			
			trace("InAppPurchaseManager: CANCELLED purchase="+e.productId+","+e.transactionId);
			notifyPurchaseStatusSignal.dispatch(e.productId,STATUS_PURCHASE_CANCELLED);
			
		}
		
		/** All transactions have been restored */
		private function onTransactionsRestored(e:StoreKitEvent):void
		{
			trace("InAppPurchaseManager: All previous transactions restored!");
		//	updateInventoryMessage();
			notifyPurchaseStatusSignal.dispatch(null,STATUS_PURCHASE_RESTORED);
			
		}
		
		/** Transaction restore has failed */
		private function onTransactionRestoreFailed(e:StoreKitErrorEvent):void
		{
			trace("InAppPurchaseManager: an error occurred in restore purchases:"+e.text);	
			notifyPurchaseStatusSignal.dispatch(null,STATUS_PURCHASE_RESTORE_FAILED);
			
		}
		
		
		
	}

}