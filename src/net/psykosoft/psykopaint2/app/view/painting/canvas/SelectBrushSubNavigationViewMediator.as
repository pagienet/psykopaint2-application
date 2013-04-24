package net.psykosoft.psykopaint2.app.view.painting.canvas
{

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpDisplaySignal;
	import net.psykosoft.psykopaint2.app.signal.notifications.NotifyPopUpMessageSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;

	public class SelectBrushSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:SelectBrushSubNavigationView;

		[Inject]
		public var notifyPopUpDisplaySignal:NotifyPopUpDisplaySignal;

		[Inject]
		public var notifyPopUpMessageSignal:NotifyPopUpMessageSignal;

		[Inject]
		public var paintModule:PaintModule;

		override public function initialize():void {

			super.initialize();
			manageStateChanges = false;
			manageMemoryWarnings = false;

			// From view.
			view.addedToStageSignal.add( onViewAddedToStage );
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewAddedToStage():void {
			view.setAvailableBrushes( paintModule.getAvailableBrushTypes() );
		}

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {

				case SelectBrushSubNavigationView.BUTTON_LABEL_SELECT_STYLE:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_STYLE ) );
					break;

				case SelectBrushSubNavigationView.BUTTON_LABEL_PICK_A_TEXTURE:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_TEXTURE ) );
					break;

				default:
					paintModule.activeBrushKit = buttonLabel;
					break;
			}
		}
	}
}
