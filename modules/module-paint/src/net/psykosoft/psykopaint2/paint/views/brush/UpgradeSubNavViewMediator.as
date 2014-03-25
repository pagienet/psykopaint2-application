package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.purchase.InAppPurchaseManager;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.UserConfigModel;
	import net.psykosoft.psykopaint2.core.signals.NotifyPurchaseStatusSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyTogglePaintingEnableSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUndoSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

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
				case InAppPurchaseManager.STATUS_PURCHASE_FAILED:
					requestUndoSignal.dispatch();
					
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					notifyTogglePaintingEnableSignal.dispatch(true);
				break;
				case InAppPurchaseManager.STATUS_PURCHASE_COMPLETE:
				case InAppPurchaseManager.STATUS_PURCHASE_NOT_REQUIRED:
					//as long as we have a single buy in product this is okayish:
					userConfig.userConfig.hasFullVersion = true;
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					notifyTogglePaintingEnableSignal.dispatch(true);
					
				break;
				case InAppPurchaseManager.STATUS_STORE_UNAVAILABLE:
					//TODO: for offline testing only - important to remove it for release!
					userConfig.userConfig.hasFullVersion = true;
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					notifyTogglePaintingEnableSignal.dispatch(true);
				break;
				
			}
			
		}
		

	}
}
