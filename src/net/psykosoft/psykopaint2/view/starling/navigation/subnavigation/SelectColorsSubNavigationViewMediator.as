package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.view.starling.popups.base.PopUpType;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectColorsSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectColorsSubNavigationView;

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
				case SelectColorsSubNavigationView.BUTTON_LABEL_PICK_A_TEXTURE:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_TEXTURE ) );
					break;
				case SelectColorsSubNavigationView.BUTTON_LABEL_PICK_AN_IMAGE:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_IMAGE ) );
					break;
				default:
					Cc.log( this, "notifying that colorization is not possible yet." );
					notifyPopUpDisplaySignal.dispatch( PopUpType.MESSAGE );
					notifyPopUpMessageSignal.dispatch( "Cannot colorize yet, feature not implemented." );
					break;
			}
		}
	}
}
