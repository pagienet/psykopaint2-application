package net.psykosoft.psykopaint2.paint.views.canvas
{

	import com.greensock.TweenLite;
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

		private var _transformMatrix:Matrix;
		private var _easelRectFromHomeView:Rectangle;
		private var _minZoomScale:Number;
		private var _addedMouseWheelListener:Boolean;
		private var _canvasRect : Rectangle;

		private const MAX_ZOOM_SCALE:Number = 3;
		private const ZOOM_MARGIN:Number = 200 * CoreSettings.GLOBAL_SCALING;

		public var offsetY : Number = 0;
		private var _firstTimeZooming : Boolean = true;

		public var zoomScale:Number = _minZoomScale;
		private var snapDelay:int;
		private var lastSnapBigger:Boolean;
		
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
			// lovely magical numbers to counter the magic numbers from the nav panel
			offsetY = offset * CoreSettings.GLOBAL_SCALING * .75 * .33;
			if (_canvasRect)
				updateAndConstrainCanvasRect(1);
		}

		// -----------------------
		// From app.
		// -----------------------

		//TODO: this is for desktop testing - remove in final version
		private function onMouseWheel( event:MouseEvent ):void {

			var sc:Number = 1 + event.delta / 50;
			_transformMatrix.identity();
			_transformMatrix.translate( -event.localX, -event.localY - offsetY );
			if (zoomScale < MAX_ZOOM_SCALE || (zoomScale == MAX_ZOOM_SCALE && sc <= 1) )
				_transformMatrix.scale(sc,sc );
			_transformMatrix.translate( event.localX, event.localY + offsetY  );

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
//				MATHIEU: NOT ANYMORE: THIS HAPPENED TO ERRATICALLY SO REMOVED
//				case GestureType.TWO_FINGER_TAP_GESTURE_RECOGNIZED:
//					requestUndoSignal.dispatch();
//					break;

				case GestureType.TRANSFORM_GESTURE_CHANGED:
					var tg:TransformGesture = (event.target as TransformGesture);
					_transformMatrix.identity();
					_transformMatrix.translate( -tg.location.x, -tg.location.y - offsetY );
					if (zoomScale < MAX_ZOOM_SCALE || (zoomScale == MAX_ZOOM_SCALE && tg.scale  <= 1) )
						_transformMatrix.scale( tg.scale, tg.scale );
					_transformMatrix.translate( tg.location.x + tg.offsetX, tg.location.y + tg.offsetY + offsetY );

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

		private function updateEaselRect():void {
			_easelRectFromHomeView = easelRectModel.absoluteScreenRect;

			_minZoomScale = _easelRectFromHomeView.width / canvasModel.width;
			zoomScale = _minZoomScale;

			// Uncomment to visualize incoming rect.
			/*view.graphics.lineStyle( 1, 0x00FF00 );
			view.graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
			view.graphics.endFill();*/
		}

		private function zoomToDefaultView():void
		{
			updateEaselRect();
			_canvasRect = _easelRectFromHomeView.clone();
			requestChangeRenderRectSignal.dispatch(_canvasRect);
			TweenLite.killTweensOf( this );
			var targetScale : Number = (canvasModel.height - 200*CoreSettings.GLOBAL_SCALING)/canvasModel.height;
			if (_firstTimeZooming) {
				TweenLite.to( this, 1, { offsetY: -175 * CoreSettings.GLOBAL_SCALING * .75 * .4, zoomScale: targetScale, onUpdate: onZoomUpdate, onComplete: onZoomToDefaultViewComplete, ease: Strong.easeInOut } );
			}
			else {
				TweenLite.to( this, 1, { zoomScale: targetScale, onUpdate: onZoomUpdate, onComplete: onZoomToDefaultViewComplete, ease: Strong.easeInOut } );
				_firstTimeZooming = false;
			}
		}

		/*private function zoomToFullView():void
		{
//			trace( this, "zoomToFullView" );
			updateEaselRect();
			updateCanvasRect( _easelRectFromHomeView );
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 1, { zoomScale: 1, onUpdate: onZoomUpdate, onComplete: onZoomToDefaultViewComplete, ease: Strong.easeInOut } );
		} */

		private function onZoomToDefaultViewComplete():void {
			notifyCanvasZoomedToDefaultViewSignal.dispatch();
		}

		private function zoomToEaselView():void {
			offsetY = 0;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 1, { zoomScale: _minZoomScale, onUpdate: onZoomUpdate, onComplete: onZoomToEaselViewComplete, ease: Strong.easeInOut } );
		}

		private function onZoomToEaselViewComplete():void {
			notifyCanvasZoomedToEaselViewSignal.dispatch();
		}

		private function onZoomUpdate():void {
			var ratio : Number = (zoomScale - _minZoomScale)/(1 - _minZoomScale);
			_canvasRect.x = (1-ratio)*_easelRectFromHomeView.x;	// linearly interpolate to 0 from zoomed out position
			_canvasRect.y = (1-ratio)*_easelRectFromHomeView.y + offsetY;

			_canvasRect.width = canvasModel.width * zoomScale;
			_canvasRect.height = canvasModel.height * zoomScale;
			// do not constrain
			requestChangeRenderRectSignal.dispatch(_canvasRect);
		}


		// -----------------------
		// Utils.
		// -----------------------

		// used for manual zooming
		private function updateAndConstrainCanvasRect(requestedScaleFactor:Number):void {
			constrainCanvasRect(requestedScaleFactor);
			requestChangeRenderRectSignal.dispatch(_canvasRect);
		}

		private function constrainCanvasRect(requestedScaleFactor:Number):void {
			
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

			if ( (getTimer()- snapDelay)<200 ||
				 ( zoomScale > 0.9 && zoomScale < 1.1 && (lastSnapBigger != (requestedScaleFactor>1) )) )
				{
				_canvasRect.width = canvasModel.width;
				_canvasRect.height = canvasModel.height;
				if ((getTimer()- snapDelay) >= 200 ) snapDelay = getTimer();
				lastSnapBigger = requestedScaleFactor>1;
				zoomScale = 1;
			}
			
			var ratio : Number = 0;
			var minPanX : Number, minPanY : Number, maxPanX : Number, maxPanY : Number;
			if( zoomScale < 1 )
			{
				ratio = (zoomScale - _minZoomScale)/(1 - _minZoomScale);
				minPanX = (1-ratio)*_easelRectFromHomeView.x;
				minPanY = (1-ratio)*_easelRectFromHomeView.y + offsetY;
				// cause a steep ramp up for the margins
				var powRatio : Number = Math.pow(ratio, 14);
				maxPanX = minPanX - ZOOM_MARGIN*powRatio;
				maxPanY = minPanY - ZOOM_MARGIN*powRatio;
				minPanX += ZOOM_MARGIN*powRatio;
				minPanY += ZOOM_MARGIN*powRatio;
			}
			else if( zoomScale > 1 ){
				// clamp to painting edges with margin
				minPanX = ZOOM_MARGIN;
				minPanY = ZOOM_MARGIN + offsetY;
				maxPanX = canvasModel.width - _canvasRect.width - ZOOM_MARGIN;
				maxPanY = canvasModel.height - _canvasRect.height - ZOOM_MARGIN + offsetY;
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
