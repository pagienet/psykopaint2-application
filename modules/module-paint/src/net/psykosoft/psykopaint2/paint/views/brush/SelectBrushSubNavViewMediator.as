package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class SelectBrushSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SelectBrushSubNavView;

		[Inject]
		public var paintModule:PaintModule;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			// Post init.
			view.setAvailableBrushes( paintModule.getAvailableBrushTypes() );
			view.setSelectedBrush( paintModule.activeBrushKit );
			view.navigation.toggleRightButtonVisibility( hasParameters() );
		}

		override protected function onButtonClicked( label:String ):void {
			switch( label ) {
				case SelectBrushSubNavView.LBL_BACK:
					requestStateChange( StateType.PAINT );
					break;
				
				case SelectBrushSubNavView.LBL_EDIT_BRUSH:
					requestStateChange( StateType.PAINT_ADJUST_BRUSH );
					break;
				
				default: // Center buttons select a brush.
					paintModule.activeBrushKit = label;
					if( hasParameters() ) {
						view.navigation.toggleRightButtonVisibility( true );
						requestStateChange( StateType.PAINT_ADJUST_BRUSH );
					}
					else {
						view.navigation.toggleRightButtonVisibility( false );
					}
					break;
			}
		}

		public function hasParameters():Boolean{
			var parameterSet:ParameterSetVO = paintModule.getCurrentBrushParameters();
			return parameterSet.parameters.length > 0;
		}
	}
}
