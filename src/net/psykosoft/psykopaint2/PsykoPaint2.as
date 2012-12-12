package net.psykosoft.psykopaint2
{

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;

	import feathers.system.DeviceCapabilities;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.config.AppConfig;
	import net.psykosoft.psykopaint2.config.Settings;
	import net.psykosoft.psykopaint2.util.DisplayContextManager;
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
			initStage();
			initStage3D();
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initStage():void {
			// Init stage.
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
		}

		private function initStage3D():void {
			// Init GPU context manager.
			var stage3dManager:Stage3DManager = Stage3DManager.getInstance( stage );
			_stage3dProxy = stage3dManager.getFreeStage3DProxy();
			_stage3dProxy.color = 0xFFFFFF;
			_stage3dProxy.antiAlias = Settings.ANTI_ALIAS;
			_stage3dProxy.width = Settings.DEVICE_SCREEN_WIDTH;
			_stage3dProxy.height = Settings.DEVICE_SCREEN_HEIGHT;
			_stage3dProxy.addEventListener( Stage3DEvent.CONTEXT3D_CREATED, onContextCreated );
			DeviceCapabilities.dpi = Settings.DEVICE_DPI;
			DeviceCapabilities.screenPixelWidth = Settings.DEVICE_SCREEN_WIDTH;
			DeviceCapabilities.screenPixelHeight = Settings.DEVICE_SCREEN_HEIGHT;
		}

		private function onContextCreated( event:Stage3DEvent ):void {
			_stage3dProxy.removeEventListener( Stage3DEvent.CONTEXT3D_CREATED, onContextCreated );
			// Rendering.
			init2D();
			init3D();
			// Continue and finish initialization.
			initRobotLegs();
			// Start loop, determined by proxy.
			_stage3dProxy.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}

		private function init3D():void {
			_away3d = new View3D();
			_away3d.stage3DProxy = _stage3dProxy;
			_away3d.shareContext = true;
			addChild( _away3d );
			DisplayContextManager.away3d = _away3d;
		}

		private function init2D():void {
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

		private function onEnterFrame( event:Event ):void {
			_away3d.render();
			_starling.nextFrame();
		}
	}
}
