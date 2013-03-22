package net.psykosoft.psykopaint2.app.view.painting.canvas
{

	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectStyleSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectStyleSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var paintModule:PaintModule;

		override public function initialize():void {

			// Init.
			view.setAvailableBrushShapes( paintModule.getAvailableBrushShapes() );

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case SelectStyleSubNavigationView.BUTTON_LABEL_EDIT_STYLE:
					requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.PAINTING_EDIT_STYLE ) );
					break;
				case SelectStyleSubNavigationView.BUTTON_LABEL_PICK_A_BRUSH:
					requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.PAINTING_SELECT_BRUSH ) );
					break;
				default:
					paintModule.setBrushShape( buttonLabel );
					break;
			}
		}
	}
}
