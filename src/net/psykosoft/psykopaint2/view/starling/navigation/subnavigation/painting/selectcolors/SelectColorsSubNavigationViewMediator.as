package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectcolors
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;

	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectColorsSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectColorsSubNavigationView;

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
				case SelectColorsSubNavigationView.BUTTON_LABEL_PICK_A_TEXTURE:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_TEXTURE ) );
					break;
				case SelectColorsSubNavigationView.BUTTON_LABEL_PICK_AN_IMAGE:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_IMAGE ) );
					break;
				default:
					Cc.warn( this, "Cannot colorize yet, feature not implemented." );
					break;
			}
		}
	}
}
