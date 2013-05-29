package net.psykosoft.psykopaint2.core
{

	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;

	import com.junkbyte.console.Cc;

	import flash.display.DisplayObject;

	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.ui.base.ViewCore;
	import net.psykosoft.psykopaint2.base.utils.DebuggingConsole;
	import net.psykosoft.psykopaint2.base.utils.PlatformUtil;
	import net.psykosoft.psykopaint2.base.utils.ShakeAndBakeConnector;
	import net.psykosoft.psykopaint2.base.utils.StackUtil;
	import net.psykosoft.psykopaint2.base.utils.XMLLoader;
	import net.psykosoft.psykopaint2.core.commands.RenderGpuCommand;
	import net.psykosoft.psykopaint2.core.config.CoreConfig;
	import net.psykosoft.psykopaint2.core.config.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestGpuRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.requests.RequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.views.base.CoreRootView;

	import org.swiftsuspenders.Injector;

	// TODO: develop ant script that moves the packaged assets to bin ( only for the core )
	// TODO: reconnect memory warnings ( conflict with the core, because it has its own memory warnings )

	public class CoreModule extends ModuleBase
	{
		[Embed(source='../../../../../../../build/ant-build.xml', mimeType="application/octet-stream")]
    	public var XmlAsset:Class;

		private var _injector:Injector;
		private var _stage3dInitialized:Boolean;
		private var _shakeAndBakeInitialized:Boolean;
		private var _shakeAndBakeConnector:ShakeAndBakeConnector;
		private var _stateSignal:RequestStateChangeSignal;
		private var _requestGpuRenderingSignal:RequestGpuRenderingSignal;
		private var _stage3d:Stage3D;
		private var _time:Number = 0;
		private var _statsTextField:TextField;
		private var _versionTextField:TextField;
		private var _fpsStackUtil:StackUtil;
		private var _renderTimeStackUtil:StackUtil;
		private var _stage3dProxy:Stage3DProxy;
		private var _coreRootView:CoreRootView;

		public var updateActive:Boolean = true;

		public function CoreModule( injector:Injector = null ) {
			super();
			_injector = injector;
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "CoreModule";
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		public function addModuleDisplay( child:DisplayObject ):void {
			_coreRootView.addToMainLayer( child );
		}

		// ---------------------------------------------------------------------
		// Initialization.
		// ---------------------------------------------------------------------

		private function initialize():void {

			getVersion();
			initDebugging();

			Cc.log( this, "Initializing... [" + name + "] v" + CoreSettings.VERSION );

			initPlatform();
			initStage();
			initStage3dASync();
			initRobotlegs();
			initShakeAndBakeAsync();
		}

		private function getVersion():void {
			var xml:XML = XML( new XmlAsset() );
			CoreSettings.VERSION = xml.property.( @name == "version" ).@value;
		}

		private function initStats():void {
			if( !CoreSettings.SHOW_STATS ) return;
			_fpsStackUtil = new StackUtil();
			_renderTimeStackUtil = new StackUtil();
			_fpsStackUtil.count = 24;
			_renderTimeStackUtil.count = 24;
			_statsTextField = new TextField();
			_statsTextField.width = 200;
			_statsTextField.selectable = false;
			_statsTextField.mouseEnabled = false;
			_statsTextField.scaleX = _statsTextField.scaleY = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1;
			addChild( _statsTextField );
		}

		private function initVersion():void {
			if( !CoreSettings.SHOW_VERSION ) return;
			_versionTextField = new TextField();
			_versionTextField.scaleX = _versionTextField.scaleY = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 2 : 1;
			_versionTextField.width = 200;
			_versionTextField.mouseEnabled = _versionTextField.selectable = false;
			_versionTextField.text = CoreSettings.NAME + ", version: " + CoreSettings.VERSION;
			_versionTextField.y = 25;
			addChild( _versionTextField );
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
			_stage3d = _stage3dProxy.stage3D;
			_stage3dProxy.addEventListener( Stage3DEvent.CONTEXT3D_CREATED, onContext3dCreated );
//			_stage3d = stage.stage3Ds[ 0 ];
//			_stage3d.addEventListener( Event.CONTEXT3D_CREATE, onContext3dCreated, false, 50 ); // TODO: ask dave why false and 50?
//			_stage3d.requestContext3D();
		}

		private function initRobotlegs():void {
//			trace( this, "initRobotlegs with stage: " + stage + ", and stage3d: " + _stage3d );
			var config:CoreConfig = new CoreConfig( this, stage, _stage3d, _stage3dProxy );
			_requestGpuRenderingSignal = config.injector.getInstance( RequestGpuRenderingSignal ); // Necessary for rendering the core on enter frame.
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
			_coreRootView = new CoreRootView();
			addChild( _coreRootView );
			initStats();
			initVersion();

			// Initial application state.
			_stateSignal.dispatch( StateType.STATE_IDLE );

			// Start enterframe.
			addEventListener( Event.ENTER_FRAME, onEnterFrame );

			// Notify.
			moduleReadySignal.dispatch( _injector );
		}

		// ---------------------------------------------------------------------
		// Loop.
		// ---------------------------------------------------------------------

		private function update():void {
			if( !updateActive ) return;
			_requestGpuRenderingSignal.dispatch();
			updateStats();
		}

		private function updateStats():void {
			if( !CoreSettings.SHOW_STATS ) return;

			var oldTime:Number = _time;
			_time = getTimer();

			var fps:Number = 1000 / (_time - oldTime);
			_fpsStackUtil.pushValue( fps );
			fps = int( _fpsStackUtil.getAverageValue() );

			_renderTimeStackUtil.pushValue( RenderGpuCommand.renderTime );
			var renderTime:int = int( _renderTimeStackUtil.getAverageValue() );

			_statsTextField.text = fps + "\n" + "Render time: " + renderTime + "ms";
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
			_stage3dProxy.removeEventListener( Event.CONTEXT3D_CREATE, onContext3dCreated );

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

		private function onEnterFrame( event:Event ):void {
			update();
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function get injector():Injector {
			return _injector;
		}
	}
}
