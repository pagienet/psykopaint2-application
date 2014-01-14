package net.psykosoft.psykopaint2.paint.views.color
{

	import flash.display.Stage;
	import flash.events.MouseEvent;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.model.UserPaintSettingsModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NavigationCanHideWithGesturesSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPickedColorChangedSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyPipetteDischargeSignal;
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
		public var notifyPipetteDischargeSignal:NotifyPipetteDischargeSignal
		
		[Inject]
		public var notifyShowPipetteSignal:NotifyShowPipetteSignal;
		
		[Inject]
		public var navigationCanHideWithGesturesSignal:NavigationCanHideWithGesturesSignal;
		
		[Inject]
		public var userPaintSettings:UserPaintSettingsModel;
		
		private var _stage:Stage;

		override public function initialize():void {

			registerView( view );
			super.initialize();
			
			// From view.
			view.enabledSignal.add( onViewEnabled );
			
			view.userPaintSettings = userPaintSettings;
			// From view.
			//view.colorChangedSignal.add( onColorChanged );

			// From app.
			notifyPickedColorChangedSignal.add( onColorChanged );
			notifyGlobalGestureSignal.add( onGlobalGestureDetected );
			notifyPipetteDischargeSignal.add( onPipetteDischarging );
			
			view.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			_stage = view.stage;
		}

		override public function destroy():void {
			super.destroy();
			view.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			notifyPickedColorChangedSignal.remove( onColorChanged );
			notifyGlobalGestureSignal.remove( onGlobalGestureDetected );
			//view.colorChangedSignal.remove( onColorChanged );
			//notifyShowPipetteSignal.remove( onShowPipette );
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
				default:
					view.openParameterWithId( id );
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
		
		private function onPipetteDischarging(pipette:Pipette ):void
		{
			view.onPipetteDischarging( pipette );
		}
		
		
		private function onGlobalGestureDetected(gestureType:String, event:GestureEvent):void
		{
			if ( gestureType == GestureType.LONG_TAP_GESTURE_BEGAN || gestureType == GestureType.VERTICAL_PAN_GESTURE_BEGAN )
			{
				var result:Object = view.canChargePipette();
				if ( result.canCharge ) notifyShowPipetteSignal.dispatch( view,  result.color, result.pos );
			} 
		}
	}
}
