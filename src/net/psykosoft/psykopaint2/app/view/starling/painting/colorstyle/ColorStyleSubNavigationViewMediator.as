package net.psykosoft.psykopaint2.app.view.starling.painting.colorstyle
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.data.types.StateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.model.canvas.ColorStylesModel;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.view.starling.painting.colorstyle.ColorStyleSubNavigationView;
	import net.psykosoft.psykopaint2.app.view.starling.popups.base.PopUpType;
	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleConfirmSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStylePresetsAvailableSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class ColorStyleSubNavigationViewMediator extends StarlingMediator
	{
		[Inject]
		public var view:ColorStyleSubNavigationView;

		[Inject]
		public var requestStateChangeSignal:RequestStateChangeSignal;

		[Inject]
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;

		[Inject]
		public var notifyColorStyleConfirmSignal:NotifyColorStyleConfirmSignal;

		[Inject]
		public var colorStyleModule:ColorStyleModule;

		[Inject]
		public var colorStylesModel:ColorStylesModel;

		override public function initialize():void {

			trace( this, "initialized" );

			// Init.
			view.setAvailableColorStyles( colorStylesModel.colorStyles );

			// From view.
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		// TODO
		/*private function onColorStyleConfirmed():void {
			notifyColorStyleConfirmSignal.dispatch();
		}

		private function onColorStyleChanged( styleName:String ):void {
			notifyColorStyleChangedSignal.dispatch( styleName );
		}*/

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {

				case ColorStyleSubNavigationView.BUTTON_LABEL_PICK_A_TEXTURE:
					// TODO: Confirm color style here.
					break;

				case ColorStyleSubNavigationView.BUTTON_LABEL_PICK_AN_IMAGE:
					requestStateChangeSignal.dispatch( new StateVO( StateType.PAINTING_SELECT_IMAGE ) );
					break;

				default:
					notifyColorStyleChangedSignal.dispatch( buttonLabel );
					break;
			}
		}
	}
}
