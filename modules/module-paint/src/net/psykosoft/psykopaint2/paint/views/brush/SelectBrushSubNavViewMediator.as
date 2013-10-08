package net.psykosoft.psykopaint2.paint.views.brush
{

	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;

	public class SelectBrushSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:SelectBrushSubNavView;

		[Inject]
		public var paintModule:BrushKitManager;

		[Inject]
		public var notifyPickedColorChangedSignal : NotifyPickedColorChangedSignal;

		private var _activeBrushId:String = "";
		
		override public function initialize():void {
			// Init.
			registerView( view );
			super.initialize();
			// From app.
			notifyPickedColorChangedSignal.add( onColorPicked );
		}

		override protected function onViewSetup():void {
			view.setAvailableBrushes( paintModule.getAvailableBrushTypes() );
			super.onViewSetup();
		}

		override protected function onViewEnabled():void {
			super.onViewEnabled();
			view.setColorButtonHex( paintModule.currentPaintColor );
		}

		override public function destroy():void {
			super.destroy();
			_activeBrushId = "";
			notifyPickedColorChangedSignal.remove( onColorPicked );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onColorPicked( hex:uint, dummy:Boolean ):void {
			view.setColorButtonHex( hex );
		}

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

				case SelectBrushSubNavView.ID_ALPHA:
					requestNavigationStateChange( NavigationStateType.PAINT_ADJUST_ALPHA );
					break;
				
				// Center buttons select a brush.
				default:
					// 1st click on a button just activates the brush, 2nd click on it, takes you to edit mode.
					if( _activeBrushId == id ) {
						if( getNumParams() != 0 ) { // Only if there are any params...
							requestNavigationStateChange( NavigationStateType.PAINT_ADJUST_BRUSH );
						}
					}
					else {
						activateBrush( id );
						_activeBrushId = id;
					}
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
