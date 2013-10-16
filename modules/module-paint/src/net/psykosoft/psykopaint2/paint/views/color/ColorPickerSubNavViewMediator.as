package net.psykosoft.psykopaint2.paint.views.color
{

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NavigationCanHideWithGesturesSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyShowPipetteSignal;
	
	import org.gestouch.events.GestureEvent;

	public class ColorPickerSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:ColorPickerSubNavView;

		[Inject]
		public var paintModule:BrushKitManager;
		
		[Inject]
		public var notifyPickedColorChangedSignal:NotifyPickedColorChangedSignal;
		
		[Inject]
		public var notifyShowPipetteSignal:NotifyShowPipetteSignal;
		
		[Inject]
		public var navigationCanHideWithGesturesSignal:NavigationCanHideWithGesturesSignal;

		private var _stage:Stage;

		override public function initialize():void {

			registerView( view );
			super.initialize();

			// From view.
			view.colorChangedSignal.add( onColorChanged );

			// From app.
			notifyPickedColorChangedSignal.add( onColorChangedFromOutside );
			notifyGlobalGestureSignal.add( onGlobalGestureDetected );
			notifyShowPipetteSignal.add( onShowPipette );
			
			view.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			_stage = view.stage;
		}

		override public function destroy():void {
			super.destroy();
			view.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			notifyPickedColorChangedSignal.remove( onColorChangedFromOutside );
			notifyGlobalGestureSignal.remove( onGlobalGestureDetected );
			view.colorChangedSignal.remove( onColorChanged );
			notifyShowPipetteSignal.remove( onShowPipette );
			if( _stage.hasEventListener( MouseEvent.MOUSE_UP ) )
				_stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			_stage = null;
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
				case ColorPickerSubNavView.ID_BACK:
					requestNavigationStateChange( NavigationStateType.PREVIOUS );
					break;
			}
		}
		
		private function onMouseDown( event:MouseEvent):void
		{
			navigationCanHideWithGesturesSignal.dispatch(false);
			_stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseUp( event:MouseEvent):void
		{
			navigationCanHideWithGesturesSignal.dispatch(true);
			_stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		// -----------------------
		// From app.
		// -----------------------

		private function onColorChangedFromOutside( newColor:uint, reallyFromOutside:Boolean ):void
		{
			if ( reallyFromOutside ) view.setCurrentColor(newColor,false,false,false);
		}
		
		private function onShowPipette( holder:Sprite, color:uint, screenPos:Point ):void
		{
			view.showPipette( holder, color, screenPos);
		}
		
		private function onGlobalGestureDetected(gestureType:String, event:GestureEvent):void
		{
			if ( gestureType == GestureType.LONG_TAP_GESTURE_BEGAN )
			{
				view.attemptPipetteCharge(true);
			}  else if ( gestureType == GestureType.VERTICAL_PAN_GESTURE_BEGAN )
			{
				 view.attemptPipetteCharge(false);
			}
		}
	}
}
