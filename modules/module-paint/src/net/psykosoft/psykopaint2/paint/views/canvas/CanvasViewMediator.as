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

		private const MAX_ZOOM_SCALE:Number = 3;

		public var zoomScale:Number = _minZoomScale;

		override public function initialize():void {

			registerView( view );
			super.initialize();
			registerEnablingState( NavigationStateType.PAINT );
			registerEnablingState( NavigationStateType.PAINT_SELECT_BRUSH );
			registerEnablingState( NavigationStateType.PAINT_ADJUST_BRUSH );
			registerEnablingState( NavigationStateType.PAINT_COLOR );
			registerEnablingState( NavigationStateType.TRANSITION_TO_HOME_MODE );
			registerEnablingState( NavigationStateType.TRANSITION_TO_PAINT_MODE );
			registerEnablingState( NavigationStateType.PREPARE_FOR_HOME_MODE );

			// Init.
			// TODO: preferrably do not do this, instead go the other way - get touch events in view, tell module how to deal with them
			paintModule.view = view;

			// From app.
			notifyGlobalGestureSignal.add( onGlobalGesture );

			requestZoomCanvasToDefaultViewSignal.add( zoomToDefaultView );
			requestZoomCanvasToEaselViewSignal.add( zoomToEaselView );

			_transformMatrix = new Matrix();

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
			
			switch( type ) {
				case GestureType.TWO_FINGER_TAP_GESTURE_RECOGNIZED:
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
			updateCanvasRect( _easelRectFromHomeView );
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
			var rect:Rectangle = new Rectangle(); //renderer.renderRect;
			var ratio : Number = (zoomScale - _minZoomScale)/(1 - _minZoomScale);
			rect.x = (1-ratio)*_easelRectFromHomeView.x;	// linearly interpolate to 0 from zoomed out position
			rect.y = (1-ratio)*_easelRectFromHomeView.y;
			rect.width = canvasModel.width * zoomScale;
			rect.height = canvasModel.height * zoomScale;
			// do not constrain
			requestChangeRenderRectSignal.dispatch(rect);
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

			if( zoomScale < 1 )
			{
				var ratio : Number = (zoomScale - _minZoomScale)/(1 - _minZoomScale);
				rect.x = (1-ratio)*_easelRectFromHomeView.x;	// linearly interpolate to 0 from zoomed out position
				rect.y = (1-ratio)*_easelRectFromHomeView.y;
			} else if ( zoomScale < 1.5 )
			{
				var offsetX:Number = rect.x / canvasModel.width;
				var offsetY:Number = rect.y / canvasModel.height;
				var ratio:Number = (zoomScale - 1) * 2;
				offsetX = ratio * offsetX + ( 1-ratio) * (1 - zoomScale) * .5;
				offsetY = ratio * offsetY + ( 1-ratio) * (1 - zoomScale) * .175;
				rect.x = offsetX * canvasModel.width;
				rect.y = offsetY * canvasModel.height;
			}
			// TODO: this causes a jump when coming from home, it seems that the .175 value needs to be calculated dynamically

			// TODO: Doesn't feel good while animating - should we use a flag here and enable it when not animating?
			/*if( zoomScale > 0.95 && zoomScale < 1.05 ) {
				zoomScale = 1;
				offsetX = 0;
				offsetY = 0;
			}*/


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
