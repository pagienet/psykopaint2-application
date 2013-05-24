package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class SelectShapeSubNavViewMediator extends MediatorBase
	{
		[Inject]
		public var view:SelectShapeSubNavView;

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
				case SelectShapeSubNavView.LBL_BACK: {
					requestStateChange( StateType.STATE_PREVIOUS );
					break;
				}
				case SelectShapeSubNavView.LBL_EDIT: {
					requestStateChange( StateType.STATE_PAINT_ADJUST_BRUSH );
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
