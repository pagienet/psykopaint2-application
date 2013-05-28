package net.psykosoft.psykopaint2.core
{

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;

	import com.junkbyte.console.Cc;

	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;
	import net.psykosoft.psykopaint2.base.utils.DebuggingConsole;
	import net.psykosoft.psykopaint2.base.utils.PlatformUtil;
	import net.psykosoft.psykopaint2.base.utils.ShakeAndBakeConnector;
	import net.psykosoft.psykopaint2.core.config.CoreConfig;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;

	import org.swiftsuspenders.Injector;

	// TODO: develop ant script that moves the packaged assets to bin ( only for the core )
	// TODO: reconnect memory warnings ( conflict with the core, because it has its own memory warnings )

	public class CoreModule extends ModuleBase
	{
		private var _injector:Injector;
		private var _stage3dInitialized:Boolean;
		private var _shakeAndBakeInitialized:Boolean;
		private var _shakeAndBakeConnector:ShakeAndBakeConnector;
		private var _stateSignal:RequestStateChangeSignal;
		private var _stage3dProxy:Stage3DProxy;
		private var _view3d:View3D;

		public function CoreModule( injector:Injector = null ) {
			super();
			trace( ">>>>> CoreModule starting..." );
			_injector = injector;
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initialize():void {

			trace( this, "initializing..." );

			initDebugging();

			Cc.log( this, "initializing core: " + CoreSettings.NAME + ", " + CoreSettings.VERSION + " ----------------------------------------" );

			initPlatform();
			initStage();
			initStage3dASync();
			initRobotlegs();
			initShakeAndBakeAsync();
		}

		private function initDebugging():void {
			var console:DebuggingConsole = new DebuggingConsole( this );
			console.traceAllStaticVariablesInClass( CoreSettings );
		}

		private function initPlatform():void {
			CoreSettings.RUNNING_ON_iPAD = PlatformUtil.isRunningOnIPad();
			CoreSettings.RUNNING_ON_RETINA_DISPLAY = PlatformUtil.isRunningOnDisplayWithDpi( CoreSettings.RESOLUTION_DPI_RETINA );
			if( CoreSettings.RUNNING_ON_RETINA_DISPLAY ) {
				ViewCore.globalScaling = 2;
			}
			Cc.log( this, "initializing platform - " +
					"running on iPad: " + CoreSettings.RUNNING_ON_iPAD + "," +
					"running on HD: " + CoreSettings.RUNNING_ON_RETINA_DISPLAY + ", " +
					"global scaling: " + ViewCore.globalScaling
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
			Cc.log( this, "initializing stage3d..." );

			var stage3dManager:Stage3DManager = Stage3DManager.getInstance( stage );
			_stage3dProxy = stage3dManager.getFreeStage3DProxy();
			_stage3dProxy.width = 1024;
			_stage3dProxy.height = 768;
			_stage3dProxy.addEventListener( Stage3DEvent.CONTEXT3D_CREATED, onContext3dCreated, false, 50 );

			// Init 3d.
			_view3d = new View3D();
			_view3d.stage3DProxy = _stage3dProxy;
			_view3d.shareContext = true;
			_view3d.camera.lens.far = 50000;
		}

		private function initRobotlegs():void {
//			trace( this, "initRobotlegs with stage: " + stage + ", and stage3d: " + _stage3d );
			var config:CoreConfig = new CoreConfig( this, stage, _stage3dProxy.stage3D, _view3d );
			_stateSignal = config.injector.getInstance( RequestStateChangeSignal ); // Necessary for rendering the core on enter frame.
			_injector = config.injector;
			Cc.log( this, "initializing robotlegs context" );
		}

		private function initShakeAndBakeAsync():void {
			_shakeAndBakeConnector = new ShakeAndBakeConnector();
			_shakeAndBakeConnector.connectedSignal.addOnce( onShakeAndBakeConnected );
			var swfUrl:String = "core-packaged/swf/core-assets.swf";
			_shakeAndBakeConnector.connectAssetsAsync( this, swfUrl );
			Cc.log( this, "initializing shake and bake: " + swfUrl + "..." );
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
			addChild( new CoreRootView( _view3d ) );

			// Initial application state.
			_stateSignal.dispatch( StateType.STATE_IDLE );

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
			Cc.log( this, "shake and bake connected" );
			_shakeAndBakeInitialized = true;
			_shakeAndBakeConnector = null;
			checkInitialized();
		}

		private function onContext3dCreated( event:Event ):void {

			Cc.log( this, "context3d created: " + _stage3dProxy.context3D );
//			addEventListener( Event.ENTER_FRAME, onEnterFrame_REMOVE_ME );
			_stage3dProxy.removeEventListener( Stage3DEvent.CONTEXT3D_CREATED, onContext3dCreated );

			// TODO: listen for context loss?
			// This simulates a context loss. A bit of googling shows that context loss on iPad is rare, but could be possible.
			/*setTimeout( function():void {
			 trace( "<<< CONTEXT3D LOSS TEST >>>" );
			 _stage3D.context3D.dispose();
			 }, 60000 );*/

			if( !_stage3dInitialized ) {
				_stage3dProxy.context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, CoreSettings.STAGE_3D_ANTI_ALIAS, true );
				_stage3dProxy.context3D.enableErrorChecking = CoreSettings.STAGE_3D_ERROR_CHECKING;
				// TODO: set stage3d props here like antialias, bg color, etc
				_stage3dInitialized = true;
				checkInitialized();
			}
		}

		// TODO: remove
		private function onEnterFrame_REMOVE_ME( event:Event ):void {
//			trace( this, "context: " + _stage3d.context3D );
		}

		public function get injector():Injector {
			return _injector;
		}

		public function get stage3dProxy():Stage3DProxy {
			return _stage3dProxy;
		}

		public function get view3d():View3D {
			return _view3d;
		}
	}
}
