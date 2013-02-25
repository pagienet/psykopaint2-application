package net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.model.state.data.States;
	import net.psykosoft.psykopaint2.app.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;

	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.SelectStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpType;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectStyleSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectStyleSubNavigationView;

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
				case SelectStyleSubNavigationView.BUTTON_LABEL_EDIT_STYLE:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_EDIT_STYLE ) );
					break;
				case SelectStyleSubNavigationView.BUTTON_LABEL_PICK_A_BRUSH:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_BRUSH ) );
					break;
				default:
					notifyPopUpDisplaySignal.dispatch( PopUpType.MESSAGE );
					notifyPopUpMessageSignal.dispatch( "Cannot use styles yet, feature not implemented." );
					break;
			}
		}
	}
}