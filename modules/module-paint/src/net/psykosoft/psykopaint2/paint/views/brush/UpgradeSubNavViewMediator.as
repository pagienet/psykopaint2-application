package net.psykosoft.psykopaint2.paint.views.brush
{

	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureManager;
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.UserConfigModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPurchaseStatusSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyTogglePaintingEnableSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestShowPopUpSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUndoSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUpdateErrorPopUpSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.core.views.popups.base.PopUpType;

	public class UpgradeSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:UpgradeSubNavView;

		[Inject]
		public var userPaintSettingsModel:UserPaintSettingsModel;

		[Inject]
		public var userConfig:UserConfigModel;
		
		[Inject]
		public var requestUndoSignal:RequestUndoSignal;
		
		[Inject]
		public var notifyTogglePaintingEnableSignal:NotifyTogglePaintingEnableSignal;
		
		[Inject]
		public var purchaseManager:InAppPurchaseManager;
		
		[Inject]
		public var notifyPurchaseStatusSignal:NotifyPurchaseStatusSignal;
		
		[Inject]
		public var requestShowPopUpSignal:RequestShowPopUpSignal;
		
		[Inject]
		public var requestUpdateErrorPopUpSignal:RequestUpdateErrorPopUpSignal;
		
		[Inject]
		public var brushKitManager : BrushKitManager;
		
		[Inject]
		public var canvasHistoryModel : CanvasHistoryModel;
		
		private var packageProductID:String;
		private var singleProductID:String
		
		override public function initialize():void {
			// Init.
			registerView( view );
			super.initialize();
			
			notifyPurchaseStatusSignal.add( onPurchaseStatus );
			
			
			
			for ( var i:int = 0; i < brushKitManager.activeBrushKit.purchasePackages.length; i++ )
			{
				var productID:String =  brushKitManager.activeBrushKit.purchasePackages[i];
				if ( InAppPurchaseManager.isBrushPackage(productID) )
				{
					if ( brushKitManager.availableProducts && brushKitManager.availableProducts[productID] )
						view.packagePrice = brushKitManager.availableProducts[productID].localizedPrice;
					else
						view.packagePrice = "0";
					packageProductID = productID;
				} else {
					if ( brushKitManager.availableProducts && brushKitManager.availableProducts[productID] )
					{
						view.singlePrice = brushKitManager.availableProducts[productID].localizedPrice;
						view.singleBrushName =  brushKitManager.availableProducts[productID].title;
					} else {
						view.singlePrice = "0";
						view.singleBrushName = brushKitManager.activeBrushKit.name;
					}
					
					singleProductID = productID;
					
				}
			}
			view.singleBrushIconID = brushKitManager.activeBrushKit.purchaseIconID;
			
		}
		
		override public function destroy():void
		{
			super.destroy();
			notifyPurchaseStatusSignal.remove( onPurchaseStatus );
		}

// -----------------------
		// From view.
		// -----------------------

		override protected function onButtonClicked( id:String ):void {

//			trace( this, "clicked: " + id);
			//STOP TRIAL MODE
			userConfig.userConfig.trialMode=false;
			switch( id ) {

				case UpgradeSubNavView.ID_CANCEL:
					requestUndoSignal.dispatch();
					canvasHistoryModel.clearHistory();	// make sure there is no trickery possible
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					notifyTogglePaintingEnableSignal.dispatch(true);
					break;

				case UpgradeSubNavView.ID_BUY_PACKAGE:
					purchaseManager.purchaseProduct(packageProductID);
					
					break;
				case UpgradeSubNavView.ID_BUY_SINGLE:
					purchaseManager.purchaseProduct(singleProductID);
					
					break;
			}
		}
		
		private function onPurchaseStatus( purchaseObjectID:String, status:int ):void
		{
			switch ( status )
			{
				case InAppPurchaseManager.STATUS_PURCHASE_CANCELLED:
					requestUndoSignal.dispatch();
					canvasHistoryModel.clearHistory();	// make sure there is no trickery possible
				break;
				
				case InAppPurchaseManager.STATUS_PURCHASE_FAILED:
					requestUndoSignal.dispatch();
					canvasHistoryModel.clearHistory();	// make sure there is no trickery possible
					
					requestShowPopUpSignal.dispatch( PopUpType.ERROR )
					requestUpdateErrorPopUpSignal.dispatch("Upgrade Failed","Oops - something went wrong with your purchase.  Please check your internet connection and try again.");
					break;
				
				case InAppPurchaseManager.STATUS_PURCHASE_COMPLETE:
				case InAppPurchaseManager.STATUS_PURCHASE_NOT_REQUIRED:
					//as long as we have a single buy in product this is okayish:
					userConfig.userConfig.markProductAsPurchased(purchaseObjectID);
					break;
				
				case InAppPurchaseManager.STATUS_STORE_UNAVAILABLE:
				case InAppPurchaseManager.STATUS_STORE_PRODUCTS_UNAVAILABLE:
					//for testing on desktop you always get the brushes:
					if ( !CoreSettings.RUNNING_ON_iPAD)  
					{
						userConfig.userConfig.markProductAsPurchased(purchaseObjectID);
					} else {
						requestUndoSignal.dispatch();
						canvasHistoryModel.clearHistory();	// make sure there is no trickery possible
						requestShowPopUpSignal.dispatch( PopUpType.ERROR )
						requestUpdateErrorPopUpSignal.dispatch("App Store is not available","Unfortunately we cannot connect to the App Store right now. Please check your internet connection and try again.");
					
						
					}
					break;
				
			}
			
			//originally I used NavigationStateType.PREVIOUS here - but this caused some issues sometimes
			requestNavigationStateChange( NavigationStateType.PAINT_ADJUST_COLOR );
			notifyTogglePaintingEnableSignal.dispatch(true);
			GestureManager.gesturesEnabled = true;
		}
		

	}
}
