package net.psykosoft.psykopaint2.paint.views.canvas
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.textures.Texture;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.modules.BrushKitManager;
	import net.psykosoft.psykopaint2.core.managers.accelerometer.GyroscopeManager;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.models.EaselRectModel;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUndoSignal;
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
		public var requestUndoSignal:RequestUndoSignal;

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
		public var easelRectModel : EaselRectModel;

		private var _transformMatrix:Matrix;
		private var _easelRectFromHomeView:Rectangle;
		private var _minZoomScale:Number;
		private var _addedMouseWheelListener:Boolean;
		private var _canvasRect : Rectangle;

		private const MAX_ZOOM_SCALE:Number = 3;
		private const ZOOM_MARGIN:Number = 100 * CoreSettings.GLOBAL_SCALING;

		public var zoomScale:Number = _minZoomScale;


		override public function initialize():void {

			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.PAINT );
			registerEnablingState( NavigationStateType.PAINT_SELECT_BRUSH );
			registerEnablingState( NavigationStateType.PAINT_ADJUST_BRUSH );
			registerEnablingState( NavigationStateType.PAINT_COLOR );
			registerEnablingState( NavigationStateType.PAINT_ADJUST_COLOR );
			registerEnablingState( NavigationStateType.TRANSITION_TO_HOME_MODE );
			registerEnablingState( NavigationStateType.TRANSITION_TO_PAINT_MODE );
			registerEnablingState( NavigationStateType.PREPARE_FOR_HOME_MODE );
			registerEnablingState( NavigationStateType.PAINT_ADJUST_ALPHA );

			// Init.
			// TODO: preferrably do not do this, instead go the other way - get touch events in view, tell module how to deal with them
			paintModule.view = view;

			// From app.
			notifyGlobalGestureSignal.add( onGlobalGesture );

			requestZoomCanvasToDefaultViewSignal.add( zoomToDefaultView );
			requestZoomCanvasToEaselViewSignal.add( zoomToEaselView );

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
			view.enabledSignal.remove(onEnabled);
			view.disabledSignal.remove(onDisabled);

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

		// -----------------------
		// From app.
		// -----------------------

		//TODO: this is for desktop testing - remove in final version
		private function onMouseWheel( event:MouseEvent ):void {

			var sc:Number = 1 + event.delta / 50;
			_transformMatrix.identity();
			_transformMatrix.translate( -event.localX, -event.localY );
			if (zoomScale < MAX_ZOOM_SCALE || (zoomScale == MAX_ZOOM_SCALE && sc <= 1) )
				_transformMatrix.scale(sc,sc );
			_transformMatrix.translate( event.localX, event.localY );

			var topLeft:Point = _transformMatrix.transformPoint( _canvasRect.topLeft );
			var bottomRight:Point = _transformMatrix.transformPoint( _canvasRect.bottomRight );

			_canvasRect.x = topLeft.x;
			_canvasRect.y = topLeft.y;
			_canvasRect.width = bottomRight.x - topLeft.x;
			_canvasRect.height = bottomRight.y - topLeft.y;
			GyroscopeManager.angleAdjustment += 0.02;
			updateAndConstrainCanvasRect();
		}

		private function onGlobalGesture( type:String, event:GestureEvent ):void {
			
			switch( type ) {
				case GestureType.TWO_FINGER_TAP_GESTURE_RECOGNIZED:
					requestUndoSignal.dispatch();
					break;

				case GestureType.TRANSFORM_GESTURE_CHANGED:
					var tg:TransformGesture = (event.target as TransformGesture);
					_transformMatrix.identity();
					_transformMatrix.translate( -tg.location.x, -tg.location.y );
					if (zoomScale < MAX_ZOOM_SCALE || (zoomScale == MAX_ZOOM_SCALE && tg.scale  <= 1) )
						_transformMatrix.scale( tg.scale, tg.scale );
					_transformMatrix.translate( tg.location.x + tg.offsetX, tg.location.y + tg.offsetY );

					var topLeft:Point = _transformMatrix.transformPoint( _canvasRect.topLeft );
					var bottomRight:Point = _transformMatrix.transformPoint( _canvasRect.bottomRight );

					_canvasRect.x = topLeft.x;
					_canvasRect.y = topLeft.y;
					_canvasRect.width = bottomRight.x - topLeft.x;
					_canvasRect.height = bottomRight.y - topLeft.y;
					updateAndConstrainCanvasRect();
					break;

			}
		}

		override protected function onStateChange( newState:String ):void {

			super.onStateChange( newState );

			if( newState ) {
				trace( this, "state index: " + newState.indexOf( NavigationStateType.PAINT ) );
				if( newState.indexOf( NavigationStateType.PAINT ) != -1 ) {

					if( !CoreSettings.RUNNING_ON_iPAD && !_addedMouseWheelListener ) {
						view.stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
						_addedMouseWheelListener = true;
						trace( this, "listener added" );
					}
				}
			}
			else {
				paintModule.stopAnimations();
				if( !CoreSettings.RUNNING_ON_iPAD && _addedMouseWheelListener ) {
					view.stage.removeEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
					_addedMouseWheelListener = false;
					trace( this, "listener removed" );
				}
			}

			// todo: remove this during state introduction
			if( newState == NavigationStateType.TRANSITION_TO_HOME_MODE )
				zoomToEaselView();

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
			TweenLite.to( this, 1, { zoomScale: targetScale, onUpdate: onZoomUpdate, onComplete: onZoomToDefaultViewComplete, ease: Strong.easeInOut } );
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

		public function zoomToEaselView():void {
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 1, { zoomScale: _minZoomScale, onUpdate: onZoomUpdate, onComplete: onZoomToEaselViewComplete, ease: Strong.easeInOut } );
		}

		private function onZoomToEaselViewComplete():void {
			notifyCanvasZoomedToEaselViewSignal.dispatch();
		}

		private function onZoomUpdate():void {
			var ratio : Number = (zoomScale - _minZoomScale)/(1 - _minZoomScale);
			_canvasRect.x = (1-ratio)*_easelRectFromHomeView.x;	// linearly interpolate to 0 from zoomed out position
			_canvasRect.y = (1-ratio)*_easelRectFromHomeView.y;
			_canvasRect.width = canvasModel.width * zoomScale;
			_canvasRect.height = canvasModel.height * zoomScale;
			// do not constrain
			requestChangeRenderRectSignal.dispatch(_canvasRect);
		}


		// -----------------------
		// Utils.
		// -----------------------

		// used for manual zooming
		private function updateAndConstrainCanvasRect():void {
			constrainCanvasRect();
			requestChangeRenderRectSignal.dispatch(_canvasRect);
		}

		private function constrainCanvasRect():void {
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

			var ratio : Number = 0;
			var minPanX : Number, minPanY : Number, maxPanX : Number, maxPanY : Number;
			if( zoomScale < 1 )
			{
				ratio = (zoomScale - _minZoomScale)/(1 - _minZoomScale);
				minPanX = (1-ratio)*_easelRectFromHomeView.x + ZOOM_MARGIN*ratio;
				minPanY = (1-ratio)*_easelRectFromHomeView.y + ZOOM_MARGIN*ratio;
				maxPanX = minPanX - ZOOM_MARGIN*ratio;
				maxPanY = minPanY - ZOOM_MARGIN*ratio;
			}
			else {
				// clamp to painting edges with margin
				minPanX = ZOOM_MARGIN;
				minPanY = ZOOM_MARGIN;
				maxPanX = canvasModel.width - _canvasRect.width - ZOOM_MARGIN;
				maxPanY = canvasModel.height - _canvasRect.height - ZOOM_MARGIN;
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
