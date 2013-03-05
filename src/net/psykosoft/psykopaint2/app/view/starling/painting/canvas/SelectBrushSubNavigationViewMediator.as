package net.psykosoft.psykopaint2.app.view.starling.painting.canvas
{

	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpType;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class SelectBrushSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:SelectBrushSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpMessageSignal:NotifyPopUpMessageSignal;

		[Inject]
		public var paintModule:PaintModule;

		override public function initialize():void {

			// Init.
			view.setAvailableBrushes( paintModule.getAvailableBrushShapes() );

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {

				case SelectBrushSubNavigationView.BUTTON_LABEL_SELECT_STYLE:
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_SELECT_STYLE ) );
					break;

				case SelectBrushSubNavigationView.BUTTON_LABEL_PICK_A_TEXTURE:
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_SELECT_TEXTURE ) );
					break;

				default:
					paintModule.setBrushShape( buttonLabel );
					break;
			}
		}
	}
}
