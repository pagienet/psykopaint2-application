package net.psykosoft.psykopaint2.core
{

	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.core.configuration.CoreConfig;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCoreModuleBootstrapCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCoreModuleBootstrapSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFrameUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;

	import robotlegs.bender.framework.api.IInjector;

	public class CoreModule extends ModuleBase
	{
		private var _coreConfig:CoreConfig;
		private var _injector:IInjector;
		private var _requestFrameUpdateSignal:RequestFrameUpdateSignal;

		public function CoreModule( injector:IInjector = null ) {

			super();
			_injector = injector;
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "CoreModule";
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function onAddedToStage( event:Event ):void {

			trace( this, "added to stage, stage size: " + stage.stageWidth + "x" + stage.stageHeight );

			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			// AIR apps launch at a default size of 500x375 or 1000x750 on retina.
			// Wait for a resize to window size before initializing anything.
			stage.addEventListener( Event.RESIZE, onStageResize );
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
		}

		private function onStageResize( event:Event ):void {
			trace( this, "stage resize: " + stage.stageWidth + "x" + stage.stageHeight );
			if( stage.stageWidth == 1024 || stage.stageWidth == 2048 ) {
				stage.removeEventListener( Event.RESIZE, onStageResize );
				initialize();
			}
		}

		private function initialize():void {
			trace( this, "initializing..." );
			CoreSettings.STAGE = stage;
			CoreSettings.DISPLAY_ROOT = this;
			initRobotlegs();
		}

		private function initRobotlegs():void {

			trace( this, "initializing robotlegs" );

			// Initialize robotlegs mappings.
			_coreConfig = new CoreConfig( this );
			_injector = _coreConfig.injector;

			// For enterframe updates...
			_requestFrameUpdateSignal = _coreConfig.injector.getInstance( RequestFrameUpdateSignal );

			// Request bootstrap.
			_coreConfig.injector.getInstance( NotifyCoreModuleBootstrapCompleteSignal ).add( onBootstrapComplete );
			_coreConfig.injector.getInstance( RequestCoreModuleBootstrapSignal ).dispatch();
		}

		private function onBootstrapComplete():void {
			trace( this, "onBootstrapComplete()" );
			_coreConfig.injector.getInstance( RequestNavigationStateChangeSignal ).dispatch( NavigationStateType.IDLE );
			moduleReadySignal.dispatch();
		}

		public function startEnterFrame():void {
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}

		private function onEnterFrame( event:Event ):void {
			_requestFrameUpdateSignal.dispatch();
		}

		public function get injector():IInjector {
			return _injector;
		}
	}
}
