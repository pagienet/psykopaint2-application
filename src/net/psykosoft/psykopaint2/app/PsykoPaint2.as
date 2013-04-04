package net.psykosoft.psykopaint2.app
{

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	import away3d.events.Stage3DEvent;

	import feathers.system.DeviceCapabilities;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.app.config.AppConfig;
	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.data.types.ApplicationStateType;
	import net.psykosoft.psykopaint2.app.data.vos.StateVO;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestRenderFrameSignal;
	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;
	import net.psykosoft.psykopaint2.app.utils.PlatformUtil;
	import net.psykosoft.psykopaint2.app.view.base.StarlingRootSprite;
	import net.psykosoft.psykopaint2.core.drawing.DrawingCore;

	import org.gestouch.core.Gestouch;
	import org.gestouch.extensions.starling.StarlingDisplayListAdapter;
	import org.gestouch.extensions.starling.StarlingTouchHitTester;
	import org.gestouch.input.NativeInputAdapter;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;

	public class PsykoPaint2 extends Sprite
	{
		protected var _appConfig:AppConfig;
		protected var _drawingCore:DrawingCore;
		protected var _stage3dProxy:Stage3DProxy;
		protected var _starling:Starling;
		protected var _away3d:View3D;

		private var _renderSignal:RequestRenderFrameSignal;

		public function PsykoPaint2() {
			super();
			initPlatform();
			initStage();
			initStage3D();
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initPlatform():void {
			Settings.RUNNING_ON_iPAD = PlatformUtil.isRunningOnIPad();
			Settings.RUNNING_ON_RETINA_DISPLAY = PlatformUtil.isRunningOnRetinaDisplay();
			Settings.RUNNING_ON_HD = Settings.RUNNING_ON_iPAD && Settings.RUNNING_ON_RETINA_DISPLAY
		}

		private function initStage():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
			mouseEnabled = mouseChildren = false; // TODO: can disable from the stage object?
			// TODO: if mouse 3d interactivity is not used, disable all mouse events in non desktop mode and ensure that away3d's picking system is disabled
		}

		private function initStage3D():void {
			// Init GPU context manager.
			var stage3dManager:Stage3DManager = Stage3DManager.getInstance( stage );
			_stage3dProxy = stage3dManager.getFreeStage3DProxy();
			DisplayContextManager.stage3dProxy = _stage3dProxy;
			_stage3dProxy.color = 0xFFFFFF;
			_stage3dProxy.antiAlias = Settings.ANTI_ALIAS;
			_stage3dProxy.addEventListener( Stage3DEvent.CONTEXT3D_CREATED, onContextCreated );
		}

		private function onContextCreated( event:Stage3DEvent ):void {

			_stage3dProxy.removeEventListener( Stage3DEvent.CONTEXT3D_CREATED, onContextCreated );

			// Init Starling and Away3D.
			init2D();
			init3D();
			// Continue and finish initialization.
			initRobotLegs();
			// Start listening for stage resizes.
			stage.addEventListener( flash.events.Event.RESIZE, onStageResize );
			onStageResize( null ); // One has already occurred while the GPU context was being fetched, so trigger one.

		}

		private function init2D():void {

			// Starling.
			Starling.handleLostContext = true;
			Starling.multitouchEnabled = true;
			_starling = new Starling( StarlingRootSprite, stage, _stage3dProxy.viewPort, _stage3dProxy.stage3D, "auto", Context3DProfile.BASELINE );
			_starling.enableErrorChecking = Settings.ENABLE_STAGE3D_ERROR_CHECKING;
			_starling.showStats = Settings.SHOW_STATS;
			_starling.shareContext = true;
			_starling.simulateMultitouch = false;
			_starling.start();
			_starling.addEventListener( starling.events.Event.CONTEXT3D_CREATE, onStarlingContextReady );
			DisplayContextManager.starling = _starling;

			// Gestouch.
			Gestouch.inputAdapter = new NativeInputAdapter( stage );
			Gestouch.addDisplayListAdapter( DisplayObject, new StarlingDisplayListAdapter() );
			Gestouch.addTouchHitTester( new StarlingTouchHitTester( _starling ), -1 );

			// Feathers.
			if( Settings.RUNNING_ON_HD ) {
				DeviceCapabilities.dpi = Settings.DPI_iPAD_RETINA;
				DeviceCapabilities.screenPixelWidth = Settings.RESOLUTION_X_iPAD_RETINA;
				DeviceCapabilities.screenPixelHeight = Settings.RESOLUTION_Y_iPAD_RETINA;
			}
			else {
				DeviceCapabilities.dpi = Settings.DPI_iPAD;
				DeviceCapabilities.screenPixelWidth = Settings.RESOLUTION_X_iPAD;
				DeviceCapabilities.screenPixelHeight = Settings.RESOLUTION_Y_iPAD;
			}
		}

		private function init3D():void {
			_away3d = new View3D();
			Debug.active = Settings.AWAY3D_DEBUG_MODE;
			_away3d.stage3DProxy = _stage3dProxy;
			_away3d.shareContext = true;
			addChild( _away3d );
			DisplayContextManager.away3d = _away3d;
		}

		private function initRobotLegs():void {

			// Starts main context.
			_appConfig = new AppConfig( this, _starling );
			_renderSignal = _appConfig.injector.getInstance( RequestRenderFrameSignal );

			// Starts core context, which handles the core drawing functionalities ( as a module ).
			_drawingCore = new DrawingCore( _appConfig.injector );
			addChild( _drawingCore );
		}

		private function onStarlingContextReady( event:starling.events.Event ):void {

			startLoop();

			// Trigger first state.
			// TODO: remove ugly time out. It's needed so that the initial state change occurs after the main view elements are on stage ( initialized ) and they can hear the state change.
			setTimeout( function():void {
				var requestStateChangeSignal:RequestStateChangeSignal = _appConfig.injector.getInstance( RequestStateChangeSignal );
				requestStateChangeSignal.dispatch( new StateVO( ApplicationStateType.SPLASH_SCREEN ) );
			}, 1000 );
		}

		private function stopLoop():void {
			trace( this, "loop stopped." );
			if( hasEventListener( flash.events.Event.ENTER_FRAME ) ) {
				removeEventListener( flash.events.Event.ENTER_FRAME, onEnterFrame );
			}
		}

		private function startLoop():void {
			stopLoop();
			trace( this, "loop started." );
			if( !hasEventListener( flash.events.Event.ENTER_FRAME ) ) {
				addEventListener( flash.events.Event.ENTER_FRAME, onEnterFrame );
			}
		}

		// ---------------------------------------------------------------------
		// Event handlers.
		// ---------------------------------------------------------------------

		private function onEnterFrame( event:flash.events.Event ):void {
//			trace( this, "main enterframe - render signal: " + _renderSignal );
			_renderSignal.dispatch();
		}

		private function onStageResize( event:flash.events.Event ):void {

			trace( this, "onStageResize - stage: " + stage.stageWidth + ", " + stage.stageHeight );

			// Starling stage size determines the size of the coordinate system,
			// which will always be set to 1024x768, the regular iPad size.
			if( Settings.RUNNING_ON_iPAD ) {
				_starling.stage.stageWidth = Settings.RESOLUTION_X_iPAD;
				_starling.stage.stageHeight = Settings.RESOLUTION_Y_iPAD;
			}
			else {
				_starling.stage.stageWidth = stage.stageWidth; // On desktop, height is slightly smaller than 768 because of window stat. bar
				_starling.stage.stageHeight = stage.stageHeight;
			}
			trace( this, "starling stage size set: " + _starling.stage.stageWidth + ", " + _starling.stage.stageHeight );

			// The view port however is dynamic and will adapt to
			// the resolution of the device.
			var viewPort:Rectangle = _starling.viewPort;
			if( Settings.RUNNING_ON_HD ) {
				viewPort.width = stage.stageWidth;
				viewPort.height = stage.stageHeight;
			}
			else {
				viewPort.width = _starling.stage.stageWidth;
				viewPort.height = _starling.stage.stageHeight;
			}
			try {
				trace( this, "starling view port set: " + viewPort.width + ", " + viewPort.height );
				trace( this, "starling content scale factor: " + _starling.contentScaleFactor );
				_stage3dProxy.width = viewPort.width;
				_stage3dProxy.height = viewPort.height;
				_starling.viewPort = viewPort;
			}
			catch( error:Error ) {
			}
		}
	}
}
