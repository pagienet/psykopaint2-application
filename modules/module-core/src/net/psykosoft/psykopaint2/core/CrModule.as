package net.psykosoft.psykopaint2.core
{

	import com.junkbyte.console.Cc;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.utils.BsDebuggingConsole;
	import net.psykosoft.psykopaint2.base.utils.BsPlatformUtil;
	import net.psykosoft.psykopaint2.base.utils.BsShakeAndBakeConnector;
	import net.psykosoft.psykopaint2.core.config.CrConfig;
	import net.psykosoft.psykopaint2.core.config.CrSettings;

	import org.osflash.signals.Signal;
	import org.swiftsuspenders.Injector;

	// TODO: develop ant script that moves the packaged assets to bin ( only for the core )
	// TODO: should we init stage3d here?

	public class CrModule extends Sprite
	{
		private var _injector:Injector;
		private var _shakeAndBakeInitialized:Boolean;
		private var _shakeAndBakeConnector:BsShakeAndBakeConnector;

		public var moduleReadySignal:Signal;

		public function CrModule( injector:Injector = null ) {
			super();
			trace( ">>>>> CrModule starting..." );
			_injector = injector;
			moduleReadySignal = new Signal();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initialize():void {

			initDebugging();

			Cc.log( this, "initializing core: " + CrSettings.NAME + ", " + CrSettings.VERSION + " ----------------------------------------" );

			initPlatform();
			initStage();
			initRobotlegs();
			// TODO: init stage3d even though the core won't use it directly, so it makes it available to upper modules?
			initShakeAndBakeAsync();
		}

		private function initDebugging():void {
			var console:BsDebuggingConsole = new BsDebuggingConsole( this );
			console.traceAllStaticVariablesInClass( CrSettings );
		}

		private function initPlatform():void {
			CrSettings.RUNNING_ON_iPAD = BsPlatformUtil.isRunningOnIPad();
			CrSettings.RUNNING_ON_RETINA_DISPLAY = BsPlatformUtil.isRunningOnDisplayWithDpi( CrSettings.RESOLUTION_DPI_RETINA );
			if( CrSettings.RUNNING_ON_RETINA_DISPLAY ) {
				CrSettings.GLOBAL_SCALING = 2;
			}
			Cc.log( this, "initializing platform - " +
					"running on iPad: " + CrSettings.RUNNING_ON_iPAD + "," +
					"running on HD: " + CrSettings.RUNNING_ON_RETINA_DISPLAY + ", " +
					"global scaling: " + CrSettings.GLOBAL_SCALING
			);
		}

		private function initStage():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW; // Note: On Desktop, the quality will be set to a lowest value of HIGH.
			Cc.log( this, "initializing stage - dimensions: " + stage.stageWidth + "x" + stage.stageHeight );
		}

		private function initRobotlegs():void {
			var config:CrConfig = new CrConfig( this );
			_injector = config.injector;
			Cc.log( this, "initializing robotlegs context" );
		}

		private function initShakeAndBakeAsync():void {
			_shakeAndBakeConnector = new BsShakeAndBakeConnector();
			_shakeAndBakeConnector.connectedSignal.addOnce( onShakeAndBakeConnected );
			var swfUrl:String = "packaged/swf/core-assets.swf";
			_shakeAndBakeConnector.connectAssetsAsync( this, swfUrl );
			Cc.log( this, "initializing shake and bake: " + swfUrl );
		}

		private function checkInitialized():void {
			Cc.log( this, "check initialized - " +
					"shakeAndBake: " + _shakeAndBakeInitialized
			);
			if( !_shakeAndBakeInitialized ) return;
			Cc.log( this, "initialized" );
			moduleReadySignal.dispatch( _injector );
		}

		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}

		private function onShakeAndBakeConnected():void {
			_shakeAndBakeInitialized = true;
			_shakeAndBakeConnector = null;
			checkInitialized();
		}
	}
}
