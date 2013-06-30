package net.psykosoft.psykopaint2.paint.views.brush
{

import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
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
			view.navigation.buttonClickedCallback = onButtonClicked;

			// Post init.
			view.setAvailableBrushes( paintModule.getAvailableBrushTypes() );
			view.setSelectedBrush( paintModule.activeBrushKit );
			view.navigation.toggleRightButtonVisibility( hasParameters() );
			view.navigation.setScrollerPosition( EditBrushCache.lastScrollerPosition );
		}

		private function onButtonClicked( label:String ):void {
			switch( label ) {
				case SelectBrushSubNavView.LBL_BACK:
					EditBrushCache.lastScrollerPosition = view.navigation.getScrollerPosition();
					requestStateChange( StateType.PREVIOUS );
					break;
				
				case SelectBrushSubNavView.LBL_EDIT_BRUSH:
					EditBrushCache.lastScrollerPosition = view.navigation.getScrollerPosition();
					requestStateChange( StateType.PAINT_ADJUST_BRUSH );
					break;
				
				default: // Center buttons select a brush.
					paintModule.activeBrushKit = label;
					EditBrushCache.setLastSelectedBrush( label );
					view.navigation.toggleRightButtonVisibility( hasParameters() );
					break;
			}
		}

		public function hasParameters():Boolean{
			var parameterSet:ParameterSetVO = paintModule.getCurrentBrushParameters();
			return parameterSet.parameters.length > 0;
		}
	}
}
