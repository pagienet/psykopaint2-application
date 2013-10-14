package net.psykosoft.psykopaint2.home
{

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestHomeViewScrollSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.home.config.HomeConfig;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;
	import net.psykosoft.psykopaint2.home.signals.NotifyHomeModuleSetUpSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestDestroyHomeModuleSignal;
	import net.psykosoft.psykopaint2.home.signals.RequestSetupHomeModuleSignal;

	public class HomeModule extends ModuleBase
	{
		private var _coreModule:CoreModule;
		private var _moduleSetUp : Boolean = true;

		public function HomeModule( core:CoreModule = null ) {
			super();

			_coreModule = core;
			if( CoreSettings.NAME == "" ) CoreSettings.NAME = "HomeModule";
			if( !_coreModule ) {
				addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );
			}
		}

		private function onAddedToStage( event:Event ):void {
			trace( this, "added to stage, stage size: " + stage.stageWidth + "x" + stage.stageHeight );
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			initialize();
		}

		public function initialize():void {
			trace( this, "initializing..." );

			// Init core module.
			if( !_coreModule )
				initStandalone();
			else {
				HomeSettings.isStandalone = false;
				init();
			}
		}

		private function initStandalone() : void
		{
			HomeSettings.isStandalone = true;
			_coreModule = new CoreModule();
			_coreModule.isStandalone = false;
			_coreModule.moduleReadySignal.addOnce(onCoreModuleReady);
			addChild(_coreModule);
		}

		private function init() : void
		{
			// Initialize robotlegs for this module.
			new HomeConfig( _coreModule.injector );

			// Notify potential super modules.
			moduleReadySignal.dispatch();
		}

		private function onCoreModuleReady():void {

			init();
			_coreModule.startEnterFrame();
			setupStandaloneModule();
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
		}

		private function onKeyUp(event : KeyboardEvent) : void
		{
			if (event.keyCode != Keyboard.F4) return;
			_moduleSetUp = !_moduleSetUp;
			if (_moduleSetUp)
				setupStandaloneModule();
			else
				destroyStandaloneModule();
		}

		private function setupStandaloneModule() : void
		{
			graphics.clear();
			_coreModule.injector.getInstance(NotifyHomeModuleSetUpSignal).addOnce(onHomeModuleSetUp);
			_coreModule.injector.getInstance(RequestSetupHomeModuleSignal).dispatch();
		}

		private function onHomeModuleSetUp() : void
		{
//			_coreModule.injector.getInstance(RequestHideSplashScreenSignal).dispatch();
			// TODO: this probably needs to be moved to some activation command
			_coreModule.injector.getInstance(RequestNavigationToggleSignal).dispatch(1);
			_coreModule.injector.getInstance(RequestHomeViewScrollSignal).dispatch(1);
			_coreModule.injector.getInstance(RequestNavigationStateChangeSignal).dispatch(NavigationStateType.HOME);
		}

		private function destroyStandaloneModule() : void
		{
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, 500, 500);
			graphics.endFill();
			_coreModule.injector.getInstance(RequestDestroyHomeModuleSignal).dispatch();
		}
	}
}
