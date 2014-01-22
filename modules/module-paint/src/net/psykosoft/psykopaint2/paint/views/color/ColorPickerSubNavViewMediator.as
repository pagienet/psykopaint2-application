package net.psykosoft.psykopaint2.paint.views.color
{

	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import net.psykosoft.psykopaint2.core.drawing.colortransfer.ColorTransfer;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NavigationCanHideWithGesturesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleChangedSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyChangePipetteColorSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPipetteChargeChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyShowPipetteSignal;
	
	import org.gestouch.events.GestureEvent;

	public class ColorPickerSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:ColorPickerSubNavView;

		[Inject]
		public var paintModule:BrushKitManager;
		
		[Inject]
		public var renderer:CanvasRenderer;
		
		[Inject]
		public var canvasModel:CanvasModel;
		
		[Inject]
		public var notifyPickedColorChangedSignal:NotifyPickedColorChangedSignal;
		
		[Inject]
		public var notifyPipetteChargeChangedSignal:NotifyPipetteChargeChangedSignal;
		
		[Inject]
		public var notifyShowPipetteSignal:NotifyShowPipetteSignal;
		
		[Inject]
		public var notifyChangePipetteColorSignal:NotifyChangePipetteColorSignal;
		
		[Inject]
		public var navigationCanHideWithGesturesSignal:NavigationCanHideWithGesturesSignal;
		
		[Inject]
		public var notifyColorStyleChangedSignal:NotifyColorStyleChangedSignal;
		
		
		[Inject]
		public var userPaintSettings:UserPaintSettingsModel;
		
		private var _stage:Stage;
		
		override public function initialize():void {

			registerView( view );
			super.initialize();
			
			// From view.
			view.enabledSignal.add( onViewEnabled );
			userPaintSettings.setDefaultValues();
			
			view.userPaintSettings = userPaintSettings;
			view.renderer = renderer;
			view.notifyChangePipetteColorSignal = notifyChangePipetteColorSignal;
			view.notifyColorStyleChangedSignal = notifyColorStyleChangedSignal;
			view.setColorTransfer(canvasModel.colorTransfer);
			view.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			// From view.
			//view.colorChangedSignal.add( onColorChanged );

			// From app.
			notifyPickedColorChangedSignal.add( onColorChanged );
			notifyGlobalGestureSignal.add( onGlobalGestureDetected );
			notifyPipetteChargeChangedSignal.add( onPipetteChargeChanged );
			
			_stage = view.stage;
			
			
			
		}

		override public function destroy():void {
			super.destroy();
			view.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			view.enabledSignal.remove(onViewEnabled);
			view.userPaintSettings = null;
			view.renderer = null;
			view.notifyChangePipetteColorSignal = null;
			view.notifyColorStyleChangedSignal = null;
			
			notifyPickedColorChangedSignal.remove( onColorChanged );
			notifyGlobalGestureSignal.remove( onGlobalGestureDetected );
			notifyPipetteChargeChangedSignal.remove( onPipetteChargeChanged );
			
			if( _stage.hasEventListener( MouseEvent.MOUSE_UP ) )
				_stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			_stage = null;
		}

		
		override protected function onViewEnabled():void {
			super.onViewEnabled();
			view.setParameters( paintModule.getCurrentBrushParameters() );
		}
		
		// -----------------------
		// From view.
		// -----------------------

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

		private function onColorChanged( newColor:uint, colorMode:int, fromSliders:Boolean ):void
		{
			view.setCurrentColor( newColor, colorMode, fromSliders);
		}
		
		private function onPipetteChargeChanged(pipette:Pipette, isCharging:Boolean ):void
		{
			if ( !isCharging) view.onPipetteDischarging( pipette );
			else view.onPipetteCharging( pipette );
			
		}
		
		
		private function onGlobalGestureDetected(gestureType:String, event:GestureEvent):void
		{
			if ( gestureType == GestureType.LONG_TAP_GESTURE_BEGAN || gestureType == GestureType.VERTICAL_PAN_GESTURE_BEGAN )
			{
				var result:Object = view.canChargePipette();
				if ( result.canCharge ) notifyShowPipetteSignal.dispatch( view,  result.color, result.pos, false );
			} else if ( gestureType == GestureType.LONG_TAP_GESTURE_ENDED )
			{
				view.onLongTapGestureEnded();
			}
			
		}
	}
}
