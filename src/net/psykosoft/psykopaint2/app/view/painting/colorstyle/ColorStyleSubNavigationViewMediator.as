package net.psykosoft.psykopaint2.app.view.painting.colorstyle
{

	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.core.drawing.modules.ColorStyleModule;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleConfirmSignal;

	public class ColorStyleSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:ColorStyleSubNavigationView;

		[Inject]
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;

		[Inject]
		public var notifyColorStyleConfirmSignal:NotifyColorStyleConfirmSignal;

		[Inject]
		public var colorStyleModule:ColorStyleModule;

//		[Inject]
//		public var notifyColorStylePresetsAvailableSignal:NotifyColorStylePresetsAvailableSignal;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

//			From core.
//			notifyColorStylePresetsAvailableSignal.add( onColorStylePresetsAvailable );

			// From view.
			view.addedToStageSignal.add( onViewAddedToStage );
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From core.
		// -----------------------

		/*private function onColorStylePresetsAvailable( presets:Array ):void {
			trace( this, "onColorStylePresetsAvailable: " + presets );
			view.setAvailableColorStyles( presets );
		}*/

		// -----------------------
		// From view.
		// -----------------------

		private function onViewAddedToStage():void {
			view.setAvailableColorStyles( colorStyleModule.getAvailableColorStylePresets() );
		}

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {

				case ColorStyleSubNavigationView.BUTTON_LABEL_PICK_A_TEXTURE:
					notifyColorStyleConfirmSignal.dispatch();
					break;

				case ColorStyleSubNavigationView.BUTTON_LABEL_PICK_AN_IMAGE:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_IMAGE ) );
					break;

				default:
					notifyColorStyleChangedSignal.dispatch( buttonLabel );
					break;
			}
		}
	}
}
