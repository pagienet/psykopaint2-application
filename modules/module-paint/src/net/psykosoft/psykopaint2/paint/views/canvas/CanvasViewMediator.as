package net.psykosoft.psykopaint2.paint.views.canvas
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;

	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.config.ModuleManager;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedBitmapData;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyExpensiveUiActionToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFreezeRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestResumeRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestSetCanvasBackgroundSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUndoSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.signals.RequestStateUpdateFromModuleActivationSignal;

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
		public var paintModule:PaintModule;

		[Inject]
		public var notifyModuleActivatedSignal:NotifyModuleActivatedSignal;

		[Inject]
		public var requestStateUpdateFromModuleActivationSignal:RequestStateUpdateFromModuleActivationSignal;
		/*
		 [Inject]
		 public var notifyNavigationToggledSignal:NotifyNavigationToggledSignal;

		 [Inject]
		 public var notifyNavigationMovingSignal:NotifyNavigationMovingSignal;
		 */
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
		public var requestSetCanvasBackgroundSignal:RequestSetCanvasBackgroundSignal;

		[Inject]
		public var stage3D:Stage3D;

		[Inject]
		public var canvasModel:CanvasModel;

		private var _transformMatrix:Matrix;

		override public function initialize():void {

			super.initialize();
			registerView( view );
			registerEnablingState( StateType.PAINT );
			registerEnablingState( StateType.PAINT_SELECT_BRUSH );
			registerEnablingState( StateType.PAINT_ADJUST_BRUSH );
			registerEnablingState( StateType.PAINT_TRANSFORM );
			registerEnablingState( StateType.TRANSITION_TO_HOME_MODE );

			// Init.
			// TODO: preferrably do not do this, instead go the other way - get touch events in view, tell module how to deal with them
			paintModule.view = view;

			// Register canvas gpu rendering in core.
			GpuRenderManager.addRenderingStep( paintModulePreRenderingStep, GpuRenderingStepType.PRE_CLEAR );
			GpuRenderManager.addRenderingStep( paintModuleNormalRenderingsStep, GpuRenderingStepType.NORMAL );

			// Drawing core to app proxying.
			notifyModuleActivatedSignal.add( onDrawingCoreModuleActivated );

			// From app.
			//notifyNavigationToggledSignal.add( onNavigationToggled );
			notifyExpensiveUiActionToggledSignal.add( onExpensiveUiTask );
			//notifyNavigationMovingSignal.add( onNavigationMoving );
			notifyGlobalGestureSignal.add( onGlobalGesture );
			requestSetCanvasBackgroundSignal.add( onSetBackgroundRequest );

			_transformMatrix = new Matrix();

			//TODO: this is for desktop testing - remove in final version
		}


		// -----------------------
		// From app.
		// -----------------------

		private function onSetBackgroundRequest( bmd:RefCountedBitmapData ):void {
			view.updateSnapshot( bmd );
		}

		//TODO: this is for desktop testing - remove in final version
		private function onMouseWheel( event:MouseEvent ):void {
			var rect:Rectangle = renderer.renderRect;

			var sc:Number = 1 + event.delta / 50;
			_transformMatrix.identity();
			_transformMatrix.translate( -event.localX, -event.localY );
			_transformMatrix.scale( sc, sc );
			_transformMatrix.translate( event.localX, event.localY );

			var topLeft:Point = _transformMatrix.transformPoint( rect.topLeft );
			var bottomRight:Point = _transformMatrix.transformPoint( rect.bottomRight );

			rect.x = topLeft.x;
			rect.y = topLeft.y;
			rect.width = bottomRight.x - topLeft.x;
			rect.height = bottomRight.y - topLeft.y;

			updateCanvasRect( rect );
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
					_transformMatrix.scale( tg.scale, tg.scale );
					_transformMatrix.translate( tg.location.x + tg.offsetX, tg.location.y + tg.offsetY );

					var topLeft:Point = _transformMatrix.transformPoint( rect.topLeft );
					var bottomRight:Point = _transformMatrix.transformPoint( rect.bottomRight );

					rect.x = topLeft.x;
					rect.y = topLeft.y;
					rect.width = bottomRight.x - topLeft.x;
					rect.height = bottomRight.y - topLeft.y;

					updateCanvasRect( rect );

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

		/*
		 private function onNavigationMoving( ratio:Number ):void {
		 if( !view.visible ) return;
		 requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight * ( 1 - .24 * ( 1 - ratio ) ) ) );
		 }

		 private function onNavigationToggled( navVisible:Boolean ):void {
		 if( navVisible ) {
		 requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight * .76 ) );
		 }
		 else {
		 requestChangeRenderRectSignal.dispatch( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight ) );
		 }
		 }
		 */

		override protected function onStateChange( newState:String ):void {
			super.onStateChange( newState );

			if( newState == StateType.PAINT ) {
				if( !CoreSettings.RUNNING_ON_iPAD ) {
					view.stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
				}
				zoomIn();
			}
			else {
				paintModule.stopAnimations();
				if( !CoreSettings.RUNNING_ON_iPAD ) {
					view.stage.removeEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
				}
			}

			if( newState == StateType.TRANSITION_TO_HOME_MODE ) {
				_waitingForZoomOutToContinueToHome = true;
				zoomOut();
			}

		}

		// -----------------------
		// Zoom animation.
		// -----------------------

		private var _waitingForZoomOutToContinueToHome:Boolean;
		private var _onZoomAnimation:Boolean;

		private const MIN_ZOOM_SCALE:Number = 0.482;
		private const MAX_ZOOM_SCALE:Number = 4;

		public var zoomScale:Number = MIN_ZOOM_SCALE;

		private function zoomIn():void {
			_onZoomAnimation = true;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 2, { zoomScale: 1, onUpdate: onZoomUpdate, onComplete: onZoomComplete, ease: Strong.easeInOut } );
		}

		private function zoomOut():void {
			_onZoomAnimation = true;
			TweenLite.killTweensOf( this );
			TweenLite.to( this, 2, { zoomScale: MIN_ZOOM_SCALE, onUpdate: onZoomUpdate, onComplete: onZoomComplete, ease: Strong.easeInOut } );
		}

		private function onZoomUpdate():void {
			var rect:Rectangle = renderer.renderRect;
			rect.width = canvasModel.width * zoomScale;
			rect.height = canvasModel.height * zoomScale;
			updateCanvasRect( rect );
		}

		private function onZoomComplete():void {
			_onZoomAnimation = false;
			if( _waitingForZoomOutToContinueToHome ) {
			    requestStateChange( StateType.HOME_ON_EASEL );
				_waitingForZoomOutToContinueToHome = false;
			}
		}

		// -----------------------
		// Utils.
		// -----------------------

		private function updateCanvasRect( rect:Rectangle ):void {
			constrainCanvasRect( rect );
			view.updateBlur( ( rect.width / canvasModel.width - MIN_ZOOM_SCALE ) / ( 1 - MIN_ZOOM_SCALE ) );
			view.updateCanvasRect( rect );
			// TODO: review this hack
			rect.x *= CoreSettings.GLOBAL_SCALING;
			rect.y *= CoreSettings.GLOBAL_SCALING;
			rect.width *= CoreSettings.GLOBAL_SCALING;
			rect.height *= CoreSettings.GLOBAL_SCALING;
			renderer.renderRect = rect;
		}

		private function constrainCanvasRect( rect:Rectangle ):void {

			var scale:Number = rect.height / canvasModel.height;
			if( scale < MIN_ZOOM_SCALE ) {
				rect.width *= ( MIN_ZOOM_SCALE / scale );
				rect.height *= ( MIN_ZOOM_SCALE / scale );
				scale = MIN_ZOOM_SCALE;
			} else if( scale > MAX_ZOOM_SCALE ) {
				rect.width *= ( MAX_ZOOM_SCALE / scale );
				rect.height *= ( MAX_ZOOM_SCALE / scale );
				scale = MAX_ZOOM_SCALE;
			}


			var offsetX:Number = rect.x / canvasModel.width;
			if( scale < 1 )
				offsetX = (1 - scale) * .5;

			var offsetY:Number = rect.y / canvasModel.height;
			if( scale < 1 )
				offsetY = (1 - scale) * .175;


			// TODO: Doesn't feel good while animating - should we use a flag here and enable it when not animating?
			if( !_onZoomAnimation && scale > 0.95 && scale < 1.05 ) {
				scale = 1;
				offsetX = 0;
				offsetY = 0;
			}

			zoomScale = scale;

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

		private function paintModuleNormalRenderingsStep():void {
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
