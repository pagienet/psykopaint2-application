package net.psykosoft.psykopaint2.book
{

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import net.psykosoft.psykopaint2.base.utils.misc.ModuleBase;
	import net.psykosoft.psykopaint2.book.config.BookConfig;
	import net.psykosoft.psykopaint2.book.config.BookSettings;
	import net.psykosoft.psykopaint2.book.signals.NotifyBookModuleSetUpSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestDestroyBookModuleSignal;
	import net.psykosoft.psykopaint2.book.signals.RequestSetUpBookModuleSignal;
	import net.psykosoft.psykopaint2.core.CoreModule;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.RequestHideSplashScreenSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;

	public class BookModule extends ModuleBase
	{
		private var _coreModule : CoreModule;
		private var _moduleSetUp : Boolean = true;

		public function BookModule(core : CoreModule = null)
		{
			super();
			_coreModule = core;
			if (CoreSettings.NAME == "") CoreSettings.NAME = "BookModule";
			if (!_coreModule) {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			initialize();
		}

		public function initialize() : void
		{
			trace(this, "initializing...");
			// Init core module.
			if (!_coreModule)
				initStandalone();
			else {
				BookSettings.isStandalone = false;
				init();
			}
		}

		private function initStandalone() : void
		{
			BookSettings.isStandalone = true;
			_coreModule = new CoreModule();
			_coreModule.isStandalone = false;
			_coreModule.moduleReadySignal.addOnce(onCoreModuleReady);
			addChild(_coreModule);
		}

		private function init() : void
		{
			// Initialize robotlegs for this module.
			new BookConfig(_coreModule.injector);

			// Notify potential super modules.
			moduleReadySignal.dispatch();
		}

		private function onCoreModuleReady() : void
		{
			init();
			_coreModule.injector.getInstance(RequestHideSplashScreenSignal).dispatch();
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
			_coreModule.injector.getInstance(NotifyBookModuleSetUpSignal).addOnce(onBookModuleSetUp);
			_coreModule.injector.getInstance(RequestSetUpBookModuleSignal).dispatch();
		}

		private function onBookModuleSetUp() : void
		{
			_coreModule.injector.getInstance(RequestNavigationToggleSignal).dispatch(1);
		}

		private function destroyStandaloneModule() : void
		{
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, 500, 500);
			graphics.endFill();
			_coreModule.injector.getInstance(RequestDestroyBookModuleSignal).dispatch();
		}
	}
}
