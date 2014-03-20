package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
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
		public var requestUndoSignal:RequestUndoSignal;
		
		[Inject]
		public var notifyTogglePaintingEnableSignal:NotifyTogglePaintingEnableSignal;
		
		override public function initialize():void {
			// Init.
			registerView( view );
			super.initialize();
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
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					notifyTogglePaintingEnableSignal.dispatch(true);
					break;
			}
		}

	}
}
