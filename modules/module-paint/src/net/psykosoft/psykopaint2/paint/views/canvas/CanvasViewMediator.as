package net.psykosoft.psykopaint2.paint.views.canvas
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Strong;
	
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.textures.Texture;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationPositionChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCanvasZoomedToDefaultViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.NotifyCanvasZoomedToEaselViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToDefaultViewSignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestZoomCanvasToEaselViewSignal;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TransformGesture;

	public class CanvasViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CanvasView;

		[Inject]
		public var stage:Stage;

		[Inject]
		public var renderer:CanvasRenderer;

		[Inject]
		public var paintModule:BrushKitManager;

		[Inject]
		public var requestChangeRenderRectSignal:RequestChangeRenderRectSignal;

		[Inject]
		public var lightingModel:LightingModel;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var stage3D:Stage3D;

		[Inject]
		public var canvasModel:CanvasModel;

		[Inject]
		public var requestZoomCanvasToDefaultViewSignal:RequestZoomCanvasToDefaultViewSignal;

		[Inject]
		public var notifyCanvasZoomedToDefaultViewSignal:NotifyCanvasZoomedToDefaultViewSignal;

		[Inject]
		public var requestZoomCanvasToEaselViewSignal:RequestZoomCanvasToEaselViewSignal;

		[Inject]
		public var notifyCanvasZoomedToEaselViewSignal:NotifyCanvasZoomedToEaselViewSignal;

		[Inject]
		public var notifyNavigationPositionChangedSignal:NotifyNavigationPositionChangedSignal;
	

		[Inject]
		public var easelRectModel : EaselRectModel;

		private var _zoomScale:Number = _minZoomScale;
		public var offsetY : Number = 0;
		
		private const MAX_ZOOM_SCALE:Number = 3;
		private const ZOOM_MARGIN:Number = 200 * CoreSettings.GLOBAL_SCALING;
		
		private var _transformMatrix:Matrix;
		private var _easelRectFromHomeView:Rectangle;
		private var _minZoomScale:Number;
		private var _addedMouseWheelListener:Boolean;
		private var _canvasRect : Rectangle;
		private var _firstTimeZooming : Boolean = true;
		private var snapDelay:int;
		private var snapped:Boolean;
		private var lastZoomDirection:int = 0;
		private var _ratio:Number= 1;
		
		public function get ratio():Number
		{
			return _ratio;
		}

		public function set ratio(value:Number):void
		{
			_ratio = value;
		}

		public function get zoomScale():Number
		{
			return _zoomScale;
		}

		public function set zoomScale(value:Number):void
		{
			_zoomScale = value;
			_canvasRect.height = value * canvasModel.height;
			_canvasRect.width = _canvasRect.height * (canvasModel.width/canvasModel.height);
			_ratio = (value - _minZoomScale)/(1 - _minZoomScale);
			
		}

		override public function initialize():void {

			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.PAINT );
			registerEnablingState( NavigationStateType.PAINT_SELECT_BRUSH );
			//registerEnablingState( NavigationStateType.PAINT_ADJUST_BRUSH );
			registerEnablingState( NavigationStateType.PAINT_ADJUST_COLOR );
			registerEnablingState( NavigationStateType.LOADING_PAINT_MODE );
			registerEnablingState( NavigationStateType.TRANSITION_TO_PAINT_MODE );
			registerEnablingState( NavigationStateType.PAINT_BUY_UPGRADE );
			//registerEnablingState( NavigationStateType.PAINT_ADJUST_ALPHA );

			// Init.
			// TODO: preferrably do not do this, instead go the other way - get touch events in view, tell module how to deal with them
			paintModule.view = view;

			// From app.
			notifyGlobalGestureSignal.add( onGlobalGesture );

			requestZoomCanvasToDefaultViewSignal.add( zoomToDefaultView );
			requestZoomCanvasToEaselViewSignal.add( zoomToEaselView );
			notifyNavigationPositionChangedSignal.add( onNavigationPositionChange );

			_transformMatrix = new Matrix();
			_canvasRect = new Rectangle(0, 0, CoreSettings.STAGE_WIDTH, CoreSettings.STAGE_HEIGHT);

			view.enabledSignal.add(onEnabled);
			view.disabledSignal.add(onDisabled);
		}
		
		

		override public function destroy():void {

			TweenLite.killTweensOf( this );

			if( !CoreSettings.RUNNING_ON_iPAD && _addedMouseWheelListener ) {
				view.stage.removeEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
				_addedMouseWheelListener = false;
				trace( this, "listener removed" );
			}

			notifyGlobalGestureSignal.remove( onGlobalGesture );
			requestZoomCanvasToDefaultViewSignal.remove( zoomToDefaultView );
			requestZoomCanvasToEaselViewSignal.remove( zoomToEaselView );
			notifyNavigationPositionChangedSignal.remove( onNavigationPositionChange );

			view.enabledSignal.remove(onEnabled);
			view.disabledSignal.remove(onDisabled);

			_canvasRect = null;

			super.destroy();
		}

		private function onEnabled() : void
		{
			// Register canvas gpu rendering in core.
			GpuRenderManager.addRenderingStep( paintModulePreRenderingStep, GpuRenderingStepType.PRE_CLEAR );
			GpuRenderManager.addRenderingStep( paintModuleNormalRenderingsStep, GpuRenderingStepType.NORMAL );
		}

		private function onDisabled() : void
		{
			// Register canvas gpu rendering in core.
			GpuRenderManager.removeRenderingStep( paintModulePreRenderingStep, GpuRenderingStepType.PRE_CLEAR );
			GpuRenderManager.removeRenderingStep( paintModuleNormalRenderingsStep, GpuRenderingStepType.NORMAL );
		}
		private function onNavigationPositionChange(offset:Number):void
		{
			//trace(this,"onNavigationPositionChange"+offset);
			
			//THE INTERFACE IS 120 PIXELS HEIGHT. SO TO CENTER THE EASEL it's 120/2
			// BUT THAT EVENT SENDS THE Y VALUE OF A CHILDREN OF NAVIGATION VIEW.
			// WHICH IS NOT A REPRESENTATIVE VALLUE. THAT'S WHY WE HARDCORE IT AT 60
			/*if(offset<0){
			offset =0;
			}else {
			offset=-60;
			}*/
			
			
			offsetY = 60*offset/175 * CoreSettings.GLOBAL_SCALING;
			//offsetY = offset * CoreSettings.GLOBAL_SCALING * .75 * .33;
			update();
			requestChangeRenderRectSignal.dispatch(_canvasRect);
			//TweenLite.to(this,0.3,{offsetY:offset,ease:Expo.easeOut,onUpdate:update});
			
		}
		
		/*private function onToggleNavRequest( value:int, autoCenter:Boolean, skipTween:Boolean ):void {
		
		var tweenDuration:Number = 0;
		if(skipTween==false){
		tweenDuration= 0.25;
		}
		if(value==1){
		//THE INTERFACE IS 120 PIXELS HEIGHT. SO TO CENTER THE EASEL it's 120/2
		// BUT THAT EVENT SENDS THE Y VALUE OF A CHILDREN OF NAVIGATION VIEW.
		// WHICH IS NOT A REPRESENTATIVE VALLUE. THAT'S WHY WE HARDCORE IT AT 60
		TweenLite.to(this,tweenDuration,{offsetY:-60,ease:Expo.easeOut,onUpdate:update});
		}else {
		TweenLite.to(this,tweenDuration,{offsetY:0,ease:Expo.easeOut,onUpdate:update});
		
		}
		
		}*/

		// -----------------------
		// From app.
		// -----------------------

		//TODO: this is for desktop testing - remove in final version
		private function onMouseWheel( event:MouseEvent ):void {

			var sc:Number = 1 + event.delta / 50;
			_transformMatrix.identity();
			_transformMatrix.translate( -event.localX, -event.localY  );
			if (zoomScale < MAX_ZOOM_SCALE || (zoomScale == MAX_ZOOM_SCALE && sc <= 1) )
				_transformMatrix.scale(sc,sc );
			_transformMatrix.translate( event.localX, event.localY  );

			var topLeft:Point = _transformMatrix.transformPoint( _canvasRect.topLeft );
			var bottomRight:Point = _transformMatrix.transformPoint( _canvasRect.bottomRight );

			_canvasRect.x = topLeft.x;
			_canvasRect.y = topLeft.y;

			_canvasRect.width = bottomRight.x - topLeft.x;
			_canvasRect.height = bottomRight.y - topLeft.y;
			updateAndConstrainCanvasRect(sc);
		}

		//TODO: this is for desktop testing - remove in final version
		private function onKeyDown( event:KeyboardEvent ):void
		{
			switch ( event.keyCode )
			{
				case Keyboard.LEFT:
					_canvasRect.x+=20;
					updateAndConstrainCanvasRect(1);
					break;
				case Keyboard.RIGHT:
					_canvasRect.x-=20;
					updateAndConstrainCanvasRect(1);
					break;
				case Keyboard.UP:
					_canvasRect.y+=20;
					updateAndConstrainCanvasRect(1);
					break;
				case Keyboard.DOWN:
					_canvasRect.y-=20;
					updateAndConstrainCanvasRect(1);
					break;
			}
		}
		
		private function onGlobalGesture( type:String, event:GestureEvent ):void {
			
			switch( type ) {
//				MATHIEU: NOT ANYMORE: THIS HAPPENED TOO ERRATICALLY SO REMOVED
//				case GestureType.TWO_FINGER_TAP_GESTURE_RECOGNIZED:
//					requestUndoSignal.dispatch();
//					break;

				case GestureType.TRANSFORM_GESTURE_CHANGED:
					var tg:TransformGesture = (event.target as TransformGesture);
					_transformMatrix.identity();
					_transformMatrix.translate( -tg.location.x, -tg.location.y );
					if (zoomScale < MAX_ZOOM_SCALE || (zoomScale == MAX_ZOOM_SCALE && tg.scale  <= 1) )
						_transformMatrix.scale( tg.scale, tg.scale );
					_transformMatrix.translate( tg.location.x + tg.offsetX, tg.location.y + tg.offsetY  );

					var topLeft:Point = _transformMatrix.transformPoint( _canvasRect.topLeft );
					var bottomRight:Point = _transformMatrix.transformPoint( _canvasRect.bottomRight );

					_canvasRect.x = topLeft.x;
					_canvasRect.y = topLeft.y;
					_canvasRect.width = bottomRight.x - topLeft.x;
					_canvasRect.height = bottomRight.y - topLeft.y;
					updateAndConstrainCanvasRect(tg.scale);
					break;

			}
		}

		override protected function onStateChange( newState:String ):void {

			super.onStateChange( newState );

			if( newState ) {
				if (newState == NavigationStateType.TRANSITION_TO_PAINT_MODE) {
					_firstTimeZooming = true;
				}

				trace( this, "state index: " + newState.indexOf( NavigationStateType.PAINT ) );
				if( newState.indexOf( NavigationStateType.PAINT ) != -1 ) {

					if( !CoreSettings.RUNNING_ON_iPAD && !_addedMouseWheelListener ) {
						view.stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
						view.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
						
						_addedMouseWheelListener = true;
						trace( this, "listener added" );
					}
				}
			}
			else {
				paintModule.stopAnimations();
				if( !CoreSettings.RUNNING_ON_iPAD && _addedMouseWheelListener ) {
					view.stage.removeEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
					view.stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
					_addedMouseWheelListener = false;
					trace( this, "listener removed" );
				}
			}
		}

	
		private function zoomToDefaultView():void
		{
			_easelRectFromHomeView = easelRectModel.absoluteScreenRect;
			_minZoomScale = _easelRectFromHomeView.width / canvasModel.width;
			zoomScale  = _minZoomScale;
			
			_canvasRect = _easelRectFromHomeView.clone();
			requestChangeRenderRectSignal.dispatch(_canvasRect);
			TweenLite.killTweensOf( this );
			var targetScale : Number = (canvasModel.height - 200*CoreSettings.GLOBAL_SCALING)/canvasModel.height;
			//var targetRatio:Number  = (targetScale - _minZoomScale)/(1 - _minZoomScale);
			if (_firstTimeZooming) {
				//MATHIEU: NO FADE IN
				//renderer.backgroundAlpha = 1;
				TweenLite.to( this, 1, { offsetY: -60, zoomScale: targetScale, onUpdate:update,onComplete: onZoomToDefaultViewComplete, ease: Strong.easeInOut } );
				//TweenLite.to( renderer, 1, { backgroundAlpha: 1 });
			}
			else {
				TweenLite.to( this, 1, {  zoomScale: targetScale, onUpdate:update,onComplete: onZoomToDefaultViewComplete, ease: Strong.easeOut } );
				_firstTimeZooming = false;
			}
		}


		private function onZoomToDefaultViewComplete():void {
			requestChangeRenderRectSignal.dispatch(_canvasRect);
			notifyCanvasZoomedToDefaultViewSignal.dispatch();
		}

		private function zoomToEaselView():void {
			//offsetY = 0;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 1, { zoomScale: _minZoomScale, onUpdate: update, onComplete: onZoomToEaselViewComplete, ease: Strong.easeOut } );
		}

		private function onZoomToEaselViewComplete():void {
			requestChangeRenderRectSignal.dispatch(_canvasRect);
			notifyCanvasZoomedToEaselViewSignal.dispatch();
		}



		// -----------------------
		// Utils.
		// -----------------------

		// used for manual zooming
		private function updateAndConstrainCanvasRect(requestedScaleFactor:Number):void {
			_ratio = requestedScaleFactor;
			update();
			requestChangeRenderRectSignal.dispatch(_canvasRect);
		}

		private function update():void {
			
		//	trace(this,"ratio = "+ratio);
			
			
			zoomScale = _canvasRect.height / canvasModel.height;
			
			if( zoomScale < _minZoomScale ) {
				_canvasRect.width *= ( _minZoomScale / zoomScale );
				_canvasRect.height *= ( _minZoomScale / zoomScale );
				zoomScale = _minZoomScale;
			} else if( zoomScale > MAX_ZOOM_SCALE ) {
				_canvasRect.width *= ( MAX_ZOOM_SCALE / zoomScale );
				_canvasRect.height *= ( MAX_ZOOM_SCALE / zoomScale );
				zoomScale = MAX_ZOOM_SCALE;
			}
			//MANAGE SNAPPING
			if ( ratio != 1 )
			{
				if ( ( ratio < 1 ? -1 : 1 ) != lastZoomDirection )
				{
					snapped = false;
				}
				lastZoomDirection = ( ratio < 1 ? -1 : 1 );
			}
			if (!snapped )
			{
				if ( zoomScale > 0.95 && zoomScale < 1.05 )
				{
					_canvasRect.width = canvasModel.width;
					_canvasRect.height = canvasModel.height;
					if ((getTimer()- snapDelay) >= 200 ) snapDelay = getTimer();
					zoomScale = 1;
					snapped = true;
				} 
			} else {
				if (  (getTimer()- snapDelay)<400 )
				{
					_canvasRect.width = canvasModel.width;
					_canvasRect.height = canvasModel.height;
					zoomScale = 1;
				} else if (  zoomScale <= 0.95 || zoomScale > 1.05 )
				{
					snapped = false;
				}	
			}
			//trace(this,"offsetY = "+offsetY);
			
			
			//var ratio : Number = 0;
			var minPanX : Number, minPanY : Number, maxPanX : Number, maxPanY : Number;
			//ON SMALLER THAN FULLSCREEN ZOOM
			if( zoomScale < 1 )
			{
				_ratio = (zoomScale - _minZoomScale)/(1 - _minZoomScale);
				minPanX = (1-_ratio)*_easelRectFromHomeView.x;
				//IF WE SHOW THE INTERFACE BAR WE MAKE SURE IT STAYS CENTERED
				minPanY = (1-_ratio)*_easelRectFromHomeView.y + offsetY;
				
				var powRatio : Number = Math.pow(_ratio, 14);
				maxPanX = minPanX - ZOOM_MARGIN*powRatio;
				maxPanY = minPanY - ZOOM_MARGIN*powRatio;
				minPanX += ZOOM_MARGIN*powRatio;
				minPanY += ZOOM_MARGIN*powRatio;
			}
			else if( zoomScale > 1 ){
				// clamp to painting edges with margin
				minPanX = ZOOM_MARGIN;
				minPanY = ZOOM_MARGIN;
				maxPanX = canvasModel.width - _canvasRect.width - ZOOM_MARGIN;
				maxPanY = canvasModel.height - _canvasRect.height - ZOOM_MARGIN;
			} else {
				minPanX = 0;
				minPanY = offsetY;
				maxPanX = 0;
				maxPanY = offsetY;
			}

			if (_canvasRect.x > minPanX) _canvasRect.x = minPanX;
			if (_canvasRect.y > minPanY) _canvasRect.y = minPanY;
			if (_canvasRect.x < maxPanX) _canvasRect.x = maxPanX;
			if (_canvasRect.y < maxPanY) _canvasRect.y = maxPanY;
		}

		// -----------------------
		// Rendering.
		// -----------------------

		private function paintModulePreRenderingStep():void {
			if( !view.isEnabled ) return;
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "pre rendering canvas" );
			}
			lightingModel.update();
		}

		private function paintModuleNormalRenderingsStep(target : Texture):void {
			if( !view.isEnabled ) return;
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "rendering canvas" );
			}
			renderer.render();
		}
	}
}
