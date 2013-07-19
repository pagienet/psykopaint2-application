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
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.config.ModuleManager;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyEaselRectInfoSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyExpensiveUiActionToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyHomeViewReadySignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFreezeRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestInteractionBlockSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestResumeRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUndoSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestCleanUpPaintModuleMemorySignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestInitPaintModuleMemorySignal;
	import net.psykosoft.psykopaint2.paint.signals.RequestStateUpdateFromModuleActivationSignal;

	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.TransformGesture;
	import org.osflash.signals.Signal;

	public class CanvasViewMediator extends MediatorBase
	{
		[Inject]
		public var view:CanvasView;

		[Inject]
		public var stage:Stage;

		[Inject]
		public var renderer:CanvasRenderer;

		[Inject]
		public var paintModule:PaintModule;

		[Inject]
		public var notifyModuleActivatedSignal:NotifyModuleActivatedSignal;

		[Inject]
		public var requestStateUpdateFromModuleActivationSignal:RequestStateUpdateFromModuleActivationSignal;

		[Inject]
		public var requestChangeRenderRectSignal:RequestChangeRenderRectSignal;

		[Inject]
		public var notifyExpensiveUiActionToggledSignal:NotifyExpensiveUiActionToggledSignal;

		[Inject]
		public var requestFreezeRenderingSignal:RequestFreezeRenderingSignal;

		[Inject]
		public var requestResumeRenderingSignal:RequestResumeRenderingSignal;

		[Inject]
		public var moduleManager:ModuleManager;

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
		public var notifyEaselRectInfoSignal:NotifyEaselRectInfoSignal;

		[Inject]
		public var requestCleanUpPaintModuleMemorySignal : RequestCleanUpPaintModuleMemorySignal;

		[Inject]
		public var requestInitPaintModuleMemorySignal : RequestInitPaintModuleMemorySignal;

		[Inject]
		public var notifyHomeModuleReadySignal:NotifyHomeViewReadySignal;

		[Inject]
		public var requestInteractionBlockSignal:RequestInteractionBlockSignal;

		private var _transformMatrix:Matrix;

		private var _easelRectFromHomeView:Rectangle;

		// -----------------------
		// Zoom animation.
		// -----------------------
		private var _waitingForZoomOutToContinueToHome:Boolean;

		private var _waitingForZoomInToContinueToPaint:Boolean;
		private var _minZoomScale:Number;

		private const MAX_ZOOM_SCALE:Number = 3;
		public var zoomScale:Number = _minZoomScale;

		override public function initialize():void {

			super.initialize();
			registerView( view );
			registerEnablingState( StateType.PAINT );
			registerEnablingState( StateType.PAINT_SELECT_BRUSH );
			registerEnablingState( StateType.PAINT_ADJUST_BRUSH );
			registerEnablingState( StateType.PAINT_COLOR );
			registerEnablingState( StateType.PAINT_SHOW_SOURCE );
			registerEnablingState( StateType.TRANSITION_TO_HOME_MODE );
			registerEnablingState( StateType.TRANSITION_TO_PAINT_MODE );
			registerEnablingState( StateType.PREPARE_FOR_HOME_MODE );

			// Init.
			// TODO: preferrably do not do this, instead go the other way - get touch events in view, tell module how to deal with them
			paintModule.view = view;

			// Register canvas gpu rendering in core.
			GpuRenderManager.addRenderingStep( paintModulePreRenderingStep, GpuRenderingStepType.PRE_CLEAR );
			GpuRenderManager.addRenderingStep( paintModuleNormalRenderingsStep, GpuRenderingStepType.NORMAL );

			// Drawing core to app proxying.
			notifyModuleActivatedSignal.add( onDrawingCoreModuleActivated );

			// From app.
			notifyEaselRectInfoSignal.add( onEaselRectInfo );
			notifyExpensiveUiActionToggledSignal.add( onExpensiveUiTask );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			notifyHomeModuleReadySignal.add( onHomeModuleReady );

			_transformMatrix = new Matrix();
		}


		// -----------------------
		// From app.
		// -----------------------

		//TODO: this is for desktop testing - remove in final version
		private function onMouseWheel( event:MouseEvent ):void {

			trace( "wheeling..." );

			var rect:Rectangle = renderer.renderRect;

			var sc:Number = 1 + event.delta / 50;
			_transformMatrix.identity();
			_transformMatrix.translate( -event.localX, -event.localY );
			if (zoomScale < MAX_ZOOM_SCALE || (zoomScale == MAX_ZOOM_SCALE && sc <= 1) )
				_transformMatrix.scale(sc,sc );
			_transformMatrix.translate( event.localX, event.localY );

			var topLeft:Point = _transformMatrix.transformPoint( rect.topLeft );
			var bottomRight:Point = _transformMatrix.transformPoint( rect.bottomRight );

			rect.x = topLeft.x;
			rect.y = topLeft.y;
			rect.width = bottomRight.x - topLeft.x;
			rect.height = bottomRight.y - topLeft.y;

			updateAndConstrainCanvasRect( rect );
		}

		private function onGlobalGesture( type:String, event:GestureEvent ):void {
			trace( this, "onGlobalGesture: " + type );
			switch( type ) {
				case GestureType.TWO_FINGER_SWIPE_LEFT:
					requestUndoSignal.dispatch();
					break;

				case GestureType.TRANSFORM_GESTURE_CHANGED:
					var tg:TransformGesture = (event.target as TransformGesture);


					var rect:Rectangle = renderer.renderRect;
					_transformMatrix.identity();
					_transformMatrix.translate( -tg.location.x, -tg.location.y );
					if (zoomScale < MAX_ZOOM_SCALE || (zoomScale == MAX_ZOOM_SCALE && tg.scale  <= 1) )
						_transformMatrix.scale( tg.scale, tg.scale );
					_transformMatrix.translate( tg.location.x + tg.offsetX, tg.location.y + tg.offsetY );

					var topLeft:Point = _transformMatrix.transformPoint( rect.topLeft );
					var bottomRight:Point = _transformMatrix.transformPoint( rect.bottomRight );

					rect.x = topLeft.x;
					rect.y = topLeft.y;
					rect.width = bottomRight.x - topLeft.x;
					rect.height = bottomRight.y - topLeft.y;

					updateAndConstrainCanvasRect( rect );

					/*
					 var angle:Number = Math.atan2(384 -tg.location.y,512 -tg.location.x );
					 GyroscopeLightController.defaultPos.x = Math.cos(angle) ;
					 GyroscopeLightController.defaultPos.y =  Math.sin(angle) ;
					 */
					break;

			}
		}

		private function onExpensiveUiTask( started:Boolean, id:String ):void {
			// TODO: analyze id properly to manage activity queues...
//			trace( this, "onExpensiveUiTask - task started: " + started + ", task id: " + id );
			if( started ) {
//				trace( this, "requesting rendering freeze" );
				requestFreezeRenderingSignal.dispatch();
			}
			else {
//				trace( this, "requesting rendering resume" );
				requestResumeRenderingSignal.dispatch();
			}
		}

		private var _addedMouseWheelListener:Boolean;

		override protected function onStateChange( newState:String ):void {

			super.onStateChange( newState );

			if( newState ) {
				trace( this, "state index: " + newState.indexOf( StateType.PAINT ) );
				if( newState.indexOf( StateType.PAINT ) != -1 ) {
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

			if (newState == StateType.PREPARE_FOR_PAINT_MODE) {
				requestInitPaintModuleMemorySignal.dispatch();
			}

			if( newState == StateType.TRANSITION_TO_PAINT_MODE ) {
				_waitingForZoomInToContinueToPaint = true;
				zoomIn();
			}

			if( newState == StateType.TRANSITION_TO_HOME_MODE ) {
				_waitingForZoomOutToContinueToHome = true;
				requestInteractionBlockSignal.dispatch( true );
				zoomOut();
			}

		}

//		private var _rectOffsetY:Number;

		private function onEaselRectInfo( rect:Rectangle ):void {
			_easelRectFromHomeView = rect.clone();

			_easelRectFromHomeView.x *= CoreSettings.GLOBAL_SCALING;
			_easelRectFromHomeView.y *= CoreSettings.GLOBAL_SCALING;
			_easelRectFromHomeView.width *= CoreSettings.GLOBAL_SCALING;
			_easelRectFromHomeView.height *= CoreSettings.GLOBAL_SCALING;
			trace( this, "easel screen rect info received: " + rect );

			_minZoomScale = _easelRectFromHomeView.width / canvasModel.width;
			zoomScale = _minZoomScale;

			// Uncomment to visualize incoming rect.
			/*view.graphics.lineStyle( 1, 0x00FF00 );
			view.graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
			view.graphics.endFill();*/
		}

		private function zoomIn():void {
			updateCanvasRect( _easelRectFromHomeView );
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 1, { zoomScale: 1, onUpdate: onZoomUpdate, onComplete: onZoomComplete, ease: Strong.easeInOut } );
		}

		private function zoomOut():void {
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 1, { zoomScale: _minZoomScale, onUpdate: onZoomUpdate, onComplete: onZoomComplete, ease: Strong.easeInOut } );
		}

		private function onZoomUpdate():void {
			var rect:Rectangle = new Rectangle(); //renderer.renderRect;
			var ratio : Number = (zoomScale - _minZoomScale)/(1 - _minZoomScale);
			// zoomScale = _minZoomScale --> ratio = 0
			// zoomScale = 1 --> (1 - _minZoomScale)/(1 - _minZoomScale) = 1
			rect.x = (1-ratio)*_easelRectFromHomeView.x;	// linearly interpolate to 0 from zoomed out position
			rect.y = (1-ratio)*_easelRectFromHomeView.y;
			rect.width = canvasModel.width * zoomScale;
			rect.height = canvasModel.height * zoomScale;
			// do not constrain
			requestChangeRenderRectSignal.dispatch(rect);
		}

		private var _waitingForHomeModuleToBeReady:Boolean;

		private function onZoomComplete():void {
			if( _waitingForZoomOutToContinueToHome ) {
				_waitingForHomeModuleToBeReady = true;
				requestStateChange( StateType.PREPARE_FOR_HOME_MODE );
				_waitingForZoomOutToContinueToHome = false;
			}
			if( _waitingForZoomInToContinueToPaint ) {
			    requestStateChange( StateType.PAINT_SELECT_BRUSH );
				requestInteractionBlockSignal.dispatch( false );
				_waitingForZoomInToContinueToPaint = false;
			}
		}

		private function onHomeModuleReady():void {
			if( _waitingForHomeModuleToBeReady ) {
				requestInteractionBlockSignal.dispatch( false );
				requestStateChange( StateType.HOME_ON_EASEL );
				requestCleanUpPaintModuleMemorySignal.dispatch();
				_waitingForHomeModuleToBeReady = false;
			}
		}

		// -----------------------
		// Utils.
		// -----------------------

		private function updateCanvasRect( rect:Rectangle ):void {
			requestChangeRenderRectSignal.dispatch(rect);
		}

		// used for manual zooming
		private function updateAndConstrainCanvasRect( rect:Rectangle ):void {
			constrainCanvasRect( rect );
			requestChangeRenderRectSignal.dispatch(rect);
		}

		private function constrainCanvasRect( rect:Rectangle ):void {

			zoomScale = rect.height / canvasModel.height;
			if( zoomScale < _minZoomScale ) {
				rect.width *= ( _minZoomScale / zoomScale );
				rect.height *= ( _minZoomScale / zoomScale );
				zoomScale = _minZoomScale;
			} else if( zoomScale > MAX_ZOOM_SCALE ) {
				rect.width *= ( MAX_ZOOM_SCALE / zoomScale );
				rect.height *= ( MAX_ZOOM_SCALE / zoomScale );
				zoomScale = MAX_ZOOM_SCALE;
			}

			var offsetX:Number = rect.x / canvasModel.width;
			var offsetY:Number = rect.y / canvasModel.height;
			if( zoomScale < 1 )
			{
				offsetX = (1 - zoomScale) * .5;
				offsetY = (1 - zoomScale) * .175;
			} else if ( zoomScale < 1.5 )
			{
				var ratio:Number = (zoomScale - 1) * 2;
				offsetX = ratio * offsetX + ( 1-ratio) * (1 - zoomScale) * .5;
				offsetY = ratio * offsetY + ( 1-ratio) * (1 - zoomScale) * .175;
			}
			// TODO: this causes a jump when coming from home, it seems that the .175 value needs to be calculated dynamically

			// TODO: Doesn't feel good while animating - should we use a flag here and enable it when not animating?
			/*if( zoomScale > 0.95 && zoomScale < 1.05 ) {
				zoomScale = 1;
				offsetX = 0;
				offsetY = 0;
			}*/

			rect.x = offsetX * canvasModel.width;
			rect.y = offsetY * canvasModel.height;
		}

		// -----------------------
		// Rendering.
		// -----------------------

		private function paintModulePreRenderingStep():void {
			if( !view.visible ) return;
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "pre rendering canvas" );
			}
			lightingModel.update();
		}

		private function paintModuleNormalRenderingsStep(target : Texture):void {
			if( !view.visible ) return;
			if( CoreSettings.DEBUG_RENDER_SEQUENCE ) {
				trace( this, "rendering canvas" );
			}
			moduleManager.render();
		}

		// -----------------------
		// Proxying.
		// -----------------------

		private function onDrawingCoreModuleActivated( vo:ModuleActivationVO ):void {
			requestStateUpdateFromModuleActivationSignal.dispatch( vo );
		}
	}
}
