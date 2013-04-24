package net.psykosoft.psykopaint2.app.view.painting.canvas
{

	import net.psykosoft.psykopaint2.app.model.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;

	public class SelectStyleSubNavigationViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var view:SelectStyleSubNavigationView;

		[Inject]
		public var paintModule:PaintModule;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			// From view.
			view.addedToStageSignal.add( onViewAddedToStage );
			view.buttonPressedSignal.add( onSubNavigationButtonPressed );

		}

		// -----------------------
		// From view.
		// -----------------------

		private function onViewAddedToStage():void {
			view.setAvailableBrushShapes( paintModule.getAvailableBrushShapes() );
		}

		private function onSubNavigationButtonPressed( buttonLabel:String ):void {
			switch( buttonLabel ) {
				case SelectStyleSubNavigationView.BUTTON_LABEL_EDIT_STYLE:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_EDIT_STYLE ) );
					break;
				case SelectStyleSubNavigationView.BUTTON_LABEL_PICK_A_BRUSH:
					requestStateChange( new StateVO( ApplicationStateType.PAINTING_SELECT_BRUSH ) );
					break;
				default:
					paintModule.setBrushShape( buttonLabel );
					break;
			}
		}
	}
}
