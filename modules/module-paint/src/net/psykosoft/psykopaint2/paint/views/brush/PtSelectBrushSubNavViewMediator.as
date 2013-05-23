package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.CrStateType;
	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;

	public class PtSelectBrushSubNavViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:PtSelectBrushSubNavView;

		[Inject]
		public var paintModule:PaintModule;

		override public function initialize():void {

			// Init.
			super.initialize();
			registerView( view );
			manageStateChanges = false;
			manageMemoryWarnings = false;
			view.setButtonClickCallback( onButtonClicked );

			// Post init.
			view.setAvailableBrushes( paintModule.getAvailableBrushTypes() );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case PtSelectBrushSubNavView.LBL_BACK: {
					requestStateChange( CrStateType.STATE_PREVIOUS );
					break;
				}
				case PtSelectBrushSubNavView.LBL_SELECT_SHAPE: {
					requestStateChange( CrStateType.STATE_PAINT_SELECT_SHAPE );
					break;
				}
				default: { // Center buttons select a brush.
					paintModule.activeBrushKit = label;
					break;
				}
			}
		}
	}
}
