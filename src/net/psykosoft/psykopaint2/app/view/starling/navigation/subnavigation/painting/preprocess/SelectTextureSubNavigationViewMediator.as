package net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess
{

	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.painting.preprocess.SelectTextureSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpType;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectTextureSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectTextureSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpMessageSignal:NotifyPopUpMessageSignal;

		override public function initialize():void {

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case SelectTextureSubNavigationView.BUTTON_LABEL_PICK_A_BRUSH:
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_SELECT_BRUSH ) );
					break;
				case SelectTextureSubNavigationView.BUTTON_LABEL_PICK_A_COLOR:
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_SELECT_COLORS ) );
					break;
				default:
					notifyPopUpDisplaySignal.dispatch( PopUpType.MESSAGE );
					notifyPopUpMessageSignal.dispatch( "Cannot texturize yet, feature not implemented." );
					break;
			}
		}
	}
}
