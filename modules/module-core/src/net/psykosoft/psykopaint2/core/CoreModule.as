package net.psykosoft.psykopaint2.core
{

	import flash.events.Event;

	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.core.configuration.CoreConfig;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyCoreModuleBootstrapCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestCoreModuleBootstrapSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestFrameUpdateSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestGpuRenderingSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal_OLD_TO_REMOVE;

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

			trace( this, "added to stage" );

			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}

		private function initialize():void {

			trace( this, "initializing..." );

			CoreSettings.STAGE = stage;
			CoreSettings.DISPLAY_ROOT = this;

			initRobotlegs();
		}

		private function initRobotlegs():void {
			trace( this, "initializing robotlegs" );
			_coreConfig = new CoreConfig( this );
			_injector = _coreConfig.injector;
			_requestFrameUpdateSignal = _coreConfig.injector.getInstance( RequestFrameUpdateSignal );
			_coreConfig.injector.getInstance( NotifyCoreModuleBootstrapCompleteSignal ).add( onBootstrapComplete );
			_coreConfig.injector.getInstance( RequestCoreModuleBootstrapSignal ).dispatch();
		}

		private function onBootstrapComplete():void {

			_coreConfig.injector.getInstance( RequestNavigationStateChangeSignal_OLD_TO_REMOVE ).dispatch( NavigationStateType.IDLE );

			if( isStandalone ) {
				_coreConfig.injector.getInstance( RequestHideSplashScreenSignal ).dispatch();
				startEnterFrame();
			}

			moduleReadySignal.dispatch();
		}

		public function startEnterFrame():void {
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}

		private function update():void {
			_requestFrameUpdateSignal.dispatch();
		}

		private function onEnterFrame( event:Event ):void {
			update();
		}

		public function get injector():IInjector {
			return _injector;
		}
	}
}
