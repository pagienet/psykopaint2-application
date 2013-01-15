package net.psykosoft.psykopaint2.view.starling.navigation.subnavigation.painting.selectbrush
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.model.state.data.States;
	import net.psykosoft.psykopaint2.model.state.vo.StateVO;
	import net.psykosoft.psykopaint2.signal.requests.RequestStateChangeSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectBrushSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectBrushSubNavigationView;

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
				case SelectBrushSubNavigationView.BUTTON_LABEL_SELECT_STYLE:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_STYLE ) );
					break;
				case SelectBrushSubNavigationView.BUTTON_LABEL_PICK_A_TEXTURE:
					requestStateChangeSignal.dispatch( new StateVO( States.PAINTING_SELECT_TEXTURE ) );
					break;
				default:
					Cc.warn( this, "Cannot use brushes yet, feature not implemented." );
					break;
			}
		}
	}
}
