package net.psykosoft.psykopaint2.paint.views.brush
{

	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
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
		}

		override protected function onViewEnabled():void {
			activateBrush( paintModule.activeBrushKit );
			super.onViewEnabled();
		}

		override protected function onViewSetup():void {
			view.setAvailableBrushes( paintModule.getAvailableBrushTypes() );
			super.onViewSetup();
		}

		override protected function onButtonClicked( label:String ):void {
			switch( label ) {

				case SelectBrushSubNavView.LBL_BACK:
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.PAINT );
					break;
				
				case SelectBrushSubNavView.LBL_EDIT_BRUSH:
					requestStateChange__OLD_TO_REMOVE( NavigationStateType.PAINT_ADJUST_BRUSH );
					break;

				// Center buttons select a brush.
				default:
					activateBrush( label );
					if( hasParameters() ) requestStateChange__OLD_TO_REMOVE( NavigationStateType.PAINT_ADJUST_BRUSH );
					break;
			}
		}

		private function activateBrush( name:String ):void {
			paintModule.activeBrushKit = name;
			view.showRightButton( hasParameters() );
		}

		private function hasParameters():Boolean{
			var parameterSet:ParameterSetVO = paintModule.getCurrentBrushParameters();
			return parameterSet.parameters.length > 0;
		}
	}
}
