package net.psykosoft.psykopaint2.paint.views.color
{

	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.models.PaintMode;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;
	import net.psykosoft.psykopaint2.paint.utils.CopyColorToBitmapDataUtil;
	import net.psykosoft.psykopaint2.paint.views.brush.SelectColorSubNavView;
	import net.psykosoft.psykopaint2.paint.views.canvas.CanvasView;
	
	import org.gestouch.events.GestureEvent;
	
	public class ColorPickerViewMediator extends MediatorBase
	{
		[Inject]
		public var view:ColorPickerView;

		[Inject]
		public var paintModule:BrushKitManager;
		
		[Inject]
		public var notifyPickedColorChangedSignal:NotifyPickedColorChangedSignal;
		
		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;
		

		override public function initialize():void {

			registerView( view );
			super.initialize();
			manageMemoryWarnings = false;

			manageStateChanges = false;
			view.enable();
			view.colorChangedSignal.add( onColorChanged );
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
