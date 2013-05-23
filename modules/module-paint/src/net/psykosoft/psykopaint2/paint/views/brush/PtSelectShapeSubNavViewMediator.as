package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.CrStateType;
	import net.psykosoft.psykopaint2.core.views.base.CrMediatorBase;

	public class PtSelectShapeSubNavViewMediator extends CrMediatorBase
	{
		[Inject]
		public var view:PtSelectShapeSubNavView;

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
			view.setAvailableShapes( paintModule.getCurrentBrushShapes() );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case PtSelectShapeSubNavView.LBL_BACK: {
					requestStateChange( CrStateType.STATE_PREVIOUS );
					break;
				}
				case PtSelectShapeSubNavView.LBL_EDIT: {
					requestStateChange( CrStateType.STATE_PAINT_ADJUST_BRUSH );
					break;
				}
				default: { // Center buttons select a shape.
					paintModule.setBrushShape( label );
					break;
				}
			}
		}
	}
}
