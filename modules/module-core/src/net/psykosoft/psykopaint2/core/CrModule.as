package net.psykosoft.psykopaint2.core
{

	import com.junkbyte.console.Cc;

	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.ui.BsViewCore;

	import net.psykosoft.psykopaint2.base.utils.BsDebuggingConsole;
	import net.psykosoft.psykopaint2.base.utils.BsPlatformUtil;
	import net.psykosoft.psykopaint2.base.utils.BsShakeAndBakeConnector;
	import net.psykosoft.psykopaint2.core.config.CrConfig;
	import net.psykosoft.psykopaint2.core.config.CrSettings;
	import net.psykosoft.psykopaint2.core.models.CrStateType;
	import net.psykosoft.psykopaint2.core.signals.requests.CrRequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.views.base.CrRootView;

	import org.osflash.signals.Signal;
	import org.swiftsuspenders.Injector;

	// TODO: develop ant script that moves the packaged assets to bin ( only for the core )
	// TODO: reconnect memory warnings ( conflict with the core, because it has its own memory warnings )

	public class CrModule extends Sprite
	{
		private var _stage3d:Stage3D;
		private var _injector:Injector;
		private var _stage3dInitialized:Boolean;
		private var _shakeAndBakeInitialized:Boolean;
		private var _shakeAndBakeConnector:BsShakeAndBakeConnector;
		private var _stateSignal:CrRequestStateChangeSignal;

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
			initStage3dASync();
			initRobotlegs();
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
				BsViewCore.globalScaling = 2;
			}
			Cc.log( this, "initializing platform - " +
					"running on iPad: " + CrSettings.RUNNING_ON_iPAD + "," +
					"running on HD: " + CrSettings.RUNNING_ON_RETINA_DISPLAY + ", " +
					"global scaling: " + BsViewCore.globalScaling
			);
		}

		private function initStage():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW; // Note: On Desktop, the quality will be set to a lowest value of HIGH.
			Cc.log( this, "initializing stage - dimensions: " + stage.stageWidth + "x" + stage.stageHeight );
		}

		private function initStage3dASync():void {
			_stage3d = stage.stage3Ds[ 0 ];
			_stage3d.addEventListener( Event.CONTEXT3D_CREATE, onContext3dCreated, false, 50 );
			_stage3d.requestContext3D();
		}

		private function initRobotlegs():void {
			var config:CrConfig = new CrConfig( this, stage, _stage3d );
			_stateSignal = config.injector.getInstance( CrRequestStateChangeSignal ); // Necessary for rendering the core on enter frame.
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
					"shakeAndBake: " + _shakeAndBakeInitialized + ", " +
					"stage3d: " + _stage3dInitialized
			);

			if( !_shakeAndBakeInitialized ) return;
			if( !_stage3dInitialized ) return;

			Cc.log( this, "initialized" );

			// Init display tree.
			addChild( new CrRootView() );

			// Initial application state.
			_stateSignal.dispatch( CrStateType.STATE_IDLE );

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

		private function onContext3dCreated( event:Event ):void {

			trace( this, "context3d created: " + _stage3d.context3D );
			_stage3d.removeEventListener( Event.CONTEXT3D_CREATE, onContext3dCreated );

			// TODO: listen for context loss?
			// This simulates a context loss. A bit of googling shows that context loss on iPad is rare, but could be possible.
			/*setTimeout( function():void {
			 trace( "<<< CONTEXT3D LOSS TEST >>>" );
			 _stage3D.context3D.dispose();
			 }, 60000 );*/

			if( !_stage3dInitialized ) {
				_stage3d.context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, CrSettings.STAGE_3D_ANTI_ALIAS, true );
				_stage3d.context3D.enableErrorChecking = CrSettings.STAGE_3D_ERROR_CHECKING;
				_stage3dInitialized = true;
				checkInitialized();
			}
		}
	}
}
