package net.psykosoft.psykopaint2.paint.views.canvas
{

	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.geom.Rectangle;
	
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.config.ModuleManager;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.drawing.modules.PaintModule;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderManager;
	import net.psykosoft.psykopaint2.core.managers.rendering.GpuRenderingStepType;
	import net.psykosoft.psykopaint2.core.model.LightingModel;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyExpensiveUiActionToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationMovingSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestChangeRenderRectSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFreezeRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestResumeRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestUndoSignal;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
	import net.psykosoft.psykopaint2.paint.commands.StartUpDrawingCoreCommand;
	import net.psykosoft.psykopaint2.paint.signals.RequestDrawingCoreStartupSignal;
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

		[Inject]
		public var notifyNavigationToggledSignal:NotifyNavigationToggledSignal;

		[Inject]
		public var notifyNavigationMovingSignal:NotifyNavigationMovingSignal;

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
		public var requestDrawingCoreStartupSignal:RequestDrawingCoreStartupSignal;

		[Inject]
		public var notifyGlobalGestureSignal:NotifyGlobalGestureSignal;

		[Inject]
		public var requestUndoSignal:RequestUndoSignal;

		[Inject]
		public var stage3D:Stage3D;

		override public function initialize():void {

			super.initialize();
			registerView( view );
			registerEnablingState( StateType.PAINT );
			registerEnablingState( StateType.PAINT_SELECT_BRUSH );
			registerEnablingState( StateType.PAINT_ADJUST_BRUSH );
			registerEnablingState( StateType.PICK_SURFACE );

			// Init.
			// TODO: preferrably do not do this, instead go the other way - get touch events in view, tell module how to deal with them
			paintModule.view = view;

			// Register canvas gpu rendering in core.
			GpuRenderManager.addRenderingStep( paintModulePreRenderingStep, GpuRenderingStepType.PRE_CLEAR );
			GpuRenderManager.addRenderingStep( paintModuleNormalRenderingsStep, GpuRenderingStepType.NORMAL );

			// Drawing core to app proxying.
			notifyModuleActivatedSignal.add( onDrawingCoreModuleActivated );

			// From app.
			notifyNavigationToggledSignal.add( onNavigationToggled );
			notifyExpensiveUiActionToggledSignal.add( onExpensiveUiTask );
			notifyNavigationMovingSignal.add( onNavigationMoving );
			notifyGlobalGestureSignal.add( onGlobalGesture );
		}

		// -----------------------
		// From app.
		// -----------------------

		private function onGlobalGesture( type:String, event:GestureEvent ):void {
			trace( this, "onGlobalGesture: " + type );
			switch( type ) {
				case GestureType.TWO_FINGER_SWIPE_LEFT: 
					requestUndoSignal.dispatch();
					break;
					
				case GestureType.TRANSFORM_GESTURE_CHANGED:
					var rect:Rectangle = renderer.renderRect;
					var tg:TransformGesture = (event.target as TransformGesture);
					rect.offset( -0.5 * ( rect.width - tg.scale * rect.width ),- 0.5 * ( rect.height - tg.scale * rect.height ));
					rect.width *= tg.scale;
					rect.height *= tg.scale;
					
					renderer.renderRect = rect;
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

		override protected function onStateChange( newState:String ):void {
			super.onStateChange( newState );
			if( newState != StateType.PAINT ) {
				paintModule.stopAnimations();
			}
			else if( !StartUpDrawingCoreCommand.ran ) {
				requestDrawingCoreStartupSignal.dispatch();
			}
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
