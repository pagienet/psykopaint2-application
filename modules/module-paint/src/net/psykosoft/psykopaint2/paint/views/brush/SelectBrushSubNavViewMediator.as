package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.UserConfigModel;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class SelectBrushSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SelectBrushSubNavView;

		[Inject]
		public var paintModule:BrushKitManager;
		
		[Inject]
		public var userPaintSettingsModel:UserPaintSettingsModel;
		
		[Inject]
		public var userConfig:UserConfigModel;

		private static var _activeBrushId:String = "";

		override public function initialize():void {
			// Init.
			registerView( view );
			super.initialize();
		}

		override protected function onViewSetup():void {
			var brushes:Vector.<String> = paintModule.getAvailableBrushTypes();
			if( _activeBrushId == "" ) _activeBrushId = brushes[ 0 ];
			view.setAvailableBrushes( brushes, _activeBrushId, userConfig.userConfig.hasBrushKit1 );
			super.onViewSetup();
		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
			view.setColorButtonHex( userPaintSettingsModel.currentColor );
		}

		override public function destroy():void {
			super.destroy();
//			_activeBrushId = "";
		}

		// -----------------------
		// From app.
		// -----------------------



		// -----------------------
		// From view.
		// -----------------------

		override protected function onButtonClicked( id:String ):void {

//			trace( this, "clicked: " + id);

			switch( id ) {

				case SelectBrushSubNavView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.PAINT );
					break;

				
				case SelectBrushSubNavView.ID_COLOR:
					requestNavigationStateChange( NavigationStateType.PAINT_ADJUST_COLOR );
					break;
				
				/*
				case SelectBrushSubNavView.ID_ALPHA:
					requestNavigationStateChange( NavigationStateType.PAINT_ADJUST_ALPHA );
					break;
				*/
				// Center buttons select a brush.
				default:
					
					activateBrush( id );
					_activeBrushId = id;
					requestNavigationStateChange( NavigationStateType.PAINT_ADJUST_COLOR );
					
					/*
					// 1st click on a button just activates the brush, 2nd click on it, takes you to edit mode.
					
					if( _activeBrushId == id ) {
						requestNavigationStateChange( NavigationStateType.PAINT_ADJUST_COLOR );
					}
					else {
						activateBrush( id );
						_activeBrushId = id;
					}
					*/
					break;
			}
		}

		// -----------------------
		// Utils.
		// -----------------------

		private function activateBrush( name:String ):void {
			paintModule.activeBrushKit = name;
		}

		private function getNumParams():uint {
			var parameterSet:ParameterSetVO = paintModule.getCurrentBrushParameters();
			return parameterSet.parameters.length;
		}
	}
}
