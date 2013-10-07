package net.psykosoft.psykopaint2.paint.views.color
{

	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;

	import org.gestouch.events.GestureEvent;

	public class ColorPickerViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:ColorPickerView;

		[Inject]
		public var paintModule:BrushKitManager;
		
		[Inject]
		public var notifyPickedColorChangedSignal:NotifyPickedColorChangedSignal;
		
		override public function initialize():void {

			registerView( view );
			super.initialize();

			// From view.
			view.colorChangedSignal.add( onColorChanged );

			// From app.
			notifyPickedColorChangedSignal.add( onColorChangedFromOutside );
			notifyGlobalGestureSignal.add( onGlobalGestureDetected );
		}
		
		
		// -----------------------
		// From view.
		// -----------------------

		private function onColorChanged():void
		{
			notifyPickedColorChangedSignal.dispatch(view.currentColor, false);
		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {
				case ColorPickerView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					break;
			}
		}
		
		// -----------------------
		// From app.
		// -----------------------

		private function onColorChangedFromOutside( newColor:uint, reallyFromOutside:Boolean ):void
		{
			if ( reallyFromOutside ) view.setCurrentColor(newColor,false,false,false);
		}
		
		private function onGlobalGestureDetected(gestureType:String, event:GestureEvent):void
		{
			if ( gestureType == GestureType.LONG_TAP_GESTURE_BEGAN )
			{
				view.attemptPipetteCharge()
			} else if ( gestureType == GestureType.LONG_TAP_GESTURE_ENDED )
			{
				view.endPipetteCharge()
			}
		}
	}
}
