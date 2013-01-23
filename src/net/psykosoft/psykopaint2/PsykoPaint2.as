package net.psykosoft.psykopaint2
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
	import flash.events.Event;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.config.AppConfig;
	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.util.DisplayContextManager;
	import net.psykosoft.psykopaint2.util.PlatformUtil;
	import net.psykosoft.psykopaint2.view.starling.base.StarlingRootSprite;
	import net.psykosoft.robotlegs.bundles.SignalCommandMapBundle;

	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;
	import robotlegs.extensions.starlingViewMap.StarlingViewMapExtension;

	import starling.core.Starling;

	public class PsykoPaint2 extends Sprite
	{
		protected var _context:IContext;
		protected var _stage3dProxy:Stage3DProxy;
		protected var _starling:Starling;
		protected var _away3d:View3D;

		public function PsykoPaint2() {
			super();
			initPlatform();
			initStage();
			initStage3D();
			// testing github stars and notifications, please delete me!
			// testing notifications 1
			// testing notifications 2
			// testing notifications 3
			// testing notifications 4
			// testing notifications 5
			// testing notifications 6 - github service hooks
			// testing notifications 7 - github service hooks
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
			// Rendering.
			init2D();
			init3D();
			// Continue and finish initialization.
			initRobotLegs();
			// Start loop, determined by proxy.
			_stage3dProxy.addEventListener( Event.ENTER_FRAME, onEnterFrameAuto );
			// Start listening for stage resizes.
			stage.addEventListener( Event.RESIZE, onStageResize );
			onStageResize( null ); // One has already occurred while the GPU context was being fetched, so trigger one.
		}

		private function init3D():void {
			_away3d = new View3D();
			if( Settings.AWAY3D_DEBUG_MODE ) {
				Debug.active = true;
			}
			_away3d.stage3DProxy = _stage3dProxy;
			_away3d.shareContext = true;
			addChild( _away3d );
			DisplayContextManager.away3d = _away3d;
		}

		private function init2D():void {

			// Starling.
			Starling.handleLostContext = true;
			Starling.multitouchEnabled = true;
			_starling = new Starling( StarlingRootSprite, stage, _stage3dProxy.viewPort, _stage3dProxy.stage3D );
			if( Settings.ENABLE_STAGE3D_ERROR_CHECKING ) {
				_starling.enableErrorChecking = true;
			}
			if( Settings.SHOW_STATS ) {
				_starling.showStats = true;
			}
			_starling.shareContext = true;
			_starling.simulateMultitouch = true;
			_starling.start();
			DisplayContextManager.starling = _starling;

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

		private function initRobotLegs():void {
			_context = new Context();
			_context.install( MVCSBundle, StarlingViewMapExtension, SignalCommandMapBundle );
			_context.configure( AppConfig, this, _starling );
			_context.configure( new ContextView( this ) );
		}

		// ---------------------------------------------------------------------
		// Event handlers.
		// ---------------------------------------------------------------------

		private function onEnterFrameAuto( event:Event ):void {
			_away3d.render();
			_starling.nextFrame();
		}

		private function onStageResize( event:Event ):void {

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
