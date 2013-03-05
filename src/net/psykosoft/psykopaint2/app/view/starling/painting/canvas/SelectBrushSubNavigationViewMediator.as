package net.psykosoft.psykopaint2.app.view.starling.painting.canvas
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.starling.painting.canvas.SelectBrushSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpType;

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
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_SELECT_STYLE ) );
					break;
				case SelectBrushSubNavigationView.BUTTON_LABEL_PICK_A_TEXTURE:
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_SELECT_TEXTURE ) );
					break;
				default:
					notifyPopUpDisplaySignal.dispatch( PopUpType.MESSAGE );
					notifyPopUpMessageSignal.dispatch( "Cannot use brushes yet, feature not implemented." );
					break;
			}
		}
	}
}
