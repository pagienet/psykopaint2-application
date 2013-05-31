package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class SelectBrushSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:SelectBrushSubNavView;

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
			view.setSelectedBrush( paintModule.activeBrushKit );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case SelectBrushSubNavView.LBL_BACK: {
					requestStateChange( StateType.STATE_PREVIOUS );
					break;
				}
				case SelectBrushSubNavView.LBL_SELECT_SHAPE: {
					requestStateChange( StateType.STATE_PAINT_SELECT_SHAPE );
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
