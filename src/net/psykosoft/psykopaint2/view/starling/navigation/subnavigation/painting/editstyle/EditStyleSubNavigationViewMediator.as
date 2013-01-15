package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.editstyle
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;

	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class EditStyleSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:EditStyleSubNavigationView;

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
				case EditStyleSubNavigationView.BUTTON_LABEL_SELECT_STYLE:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_STYLE ) );
					break;
				default:
					Cc.warn( this, "Cannot use properties yet, feature not implemented." );
					break;
			}
		}
	}
}
