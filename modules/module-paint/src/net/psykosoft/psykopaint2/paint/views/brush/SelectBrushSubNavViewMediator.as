package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class SelectBrushSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SelectBrushSubNavView;

		[Inject]
		public var paintModule:BrushKitManager;
		
		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
		}

		override protected function onViewSetup():void {
			view.setAvailableBrushes( paintModule.getAvailableBrushTypes() );
			super.onViewSetup();
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				case SelectBrushSubNavView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.PAINT );
					break;

				case SelectBrushSubNavView.ID_COLOR:
					requestNavigationStateChange( NavigationStateType.PAINT_ADJUST_COLOR );
					break;
				
				// Center buttons select a brush.
				default:
					activateBrush( id );
					if( hasParameters() ) requestNavigationStateChange( NavigationStateType.PAINT_ADJUST_BRUSH );
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
