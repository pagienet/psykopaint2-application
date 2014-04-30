package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;
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
		
		
		override public function initialize():void {
			// Init.
			registerView( view );
			super.initialize();
			
			notifyPurchaseStatusSignal.add( onPurchaseStatus );
		}
		
		
		// -----------------------
		// From view.
		// -----------------------

		override protected function onButtonClicked( id:String ):void {

//			trace( this, "clicked: " + id);

			switch( id ) {

				case UpgradeSubNavView.ID_CANCEL:
					requestUndoSignal.dispatch();
					
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					notifyTogglePaintingEnableSignal.dispatch(true);
					break;

				case UpgradeSubNavView.ID_BUY:
					purchaseManager.purchaseFullUpgrade();
					
					break;
			}
		}
		
		private function onPurchaseStatus( purchaseObjectID:String, status:int ):void
		{
			switch ( status )
			{
				case InAppPurchaseManager.STATUS_PURCHASE_CANCELLED:
					requestUndoSignal.dispatch();
				break;
				
				case InAppPurchaseManager.STATUS_PURCHASE_FAILED:
					requestUndoSignal.dispatch();
					requestShowPopUpSignal.dispatch( PopUpType.ERROR )
					requestUpdateErrorPopUpSignal.dispatch("Upgrade Failed","Oops - something went wrong with your purchase.  Please check your internet connection and try again.");
					break;
				
				case InAppPurchaseManager.STATUS_PURCHASE_COMPLETE:
				case InAppPurchaseManager.STATUS_PURCHASE_NOT_REQUIRED:
					//as long as we have a single buy in product this is okayish:
					userConfig.userConfig.hasFullVersion = true;
					break;
				
				case InAppPurchaseManager.STATUS_STORE_UNAVAILABLE:
					//for testing on desktop you always get the brushes:
					//if ( !CoreSettings.RUNNING_ON_iPAD)  userConfig.userConfig.hasFullVersion = true;
					requestUndoSignal.dispatch();
					requestShowPopUpSignal.dispatch( PopUpType.ERROR )
					requestUpdateErrorPopUpSignal.dispatch("App Store is not available","Unfortunately we cannot connect to the App Store right now. Please check your internet connection and try again.");
					break;
				
			}
			
			//originally I used NavigationStateType.PREVIOUS here - but this caused some issues sometimes
			requestNavigationStateChange( NavigationStateType.PAINT_ADJUST_COLOR );
			notifyTogglePaintingEnableSignal.dispatch(true);
		}
		

	}
}
