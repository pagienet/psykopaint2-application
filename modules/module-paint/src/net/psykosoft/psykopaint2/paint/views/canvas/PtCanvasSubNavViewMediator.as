package net.psykosoft.psykopaint2.paint.views.canvas
{

	import net.psykosoft.psykopaint2.core.models.CrStateType;
	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;

	public class PtCanvasSubNavViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:PtCanvasSubNavView;

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
				case PtCanvasSubNavView.LBL_PICK_AN_IMAGE: {
					requestStateChange( CrStateType.STATE_PICK_IMAGE );
					break;
				}
				case PtCanvasSubNavView.LBL_PICK_A_BRUSH: {
					requestStateChange( CrStateType.STATE_PAINT_SELECT_BRUSH );
					break;
				}
			}
		}
	}
}
