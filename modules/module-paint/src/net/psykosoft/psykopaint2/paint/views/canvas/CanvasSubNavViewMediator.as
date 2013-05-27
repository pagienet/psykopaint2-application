package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.RequestClearCanvasSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class CanvasSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CanvasSubNavView;

		[Inject]
		public var requestClearCanvasSignal:RequestClearCanvasSignal;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case CanvasSubNavView.LBL_PICK_AN_IMAGE: {
					requestStateChange( StateType.STATE_PICK_IMAGE );
					break;
				}
				case CanvasSubNavView.LBL_PICK_A_BRUSH: {
					requestStateChange( StateType.STATE_PAINT_SELECT_BRUSH );
					break;
				}
				case CanvasSubNavView.LBL_CLEAR: {
					requestClearCanvasSignal.dispatch();
					break;
				}
			}
		}
	}
}
