package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectstyle
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;

	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectStyleSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectStyleSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

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
					Cc.warn( this, "Cannot use styles yet, feature not implemented." );
					break;
			}
		}
	}
}
