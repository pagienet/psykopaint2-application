package net.psykosoft.psykopaint2.app.config
{
	import net.psykosoft.psykopaint2.app.commands.CreateCanvasBackgroundCommand;
	import net.psykosoft.psykopaint2.app.signals.NotifyCanvasBackgroundSetSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreateCanvasBackgroundSignal;
	import net.psykosoft.psykopaint2.app.states.BookState;
	import net.psykosoft.psykopaint2.app.states.CropState;
	import net.psykosoft.psykopaint2.app.states.HomeState;
	import net.psykosoft.psykopaint2.app.states.TransitionSplashToHomeState;
	import net.psykosoft.psykopaint2.app.states.PaintState;
	import net.psykosoft.psykopaint2.app.states.TransitionHomeToPaintState;
	import net.psykosoft.psykopaint2.home.HomeModule;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.HomeViewMediator;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IInjector;

	public class AppConfig
	{
		private var _injector:IInjector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function AppConfig( injector:IInjector ) {
			super();

			_injector = injector;
			_mediatorMap = _injector.getInstance( IMediatorMap );
			_commandMap = _injector.getInstance( ISignalCommandMap );

			mapMediators();
			mapCommands();
			mapNotifications();
			mapSingletons();
			mapServices();
			mapModels();
		}

		public function get injector():IInjector {
			return _injector;
		}

		// -----------------------
		// Models.
		// -----------------------

		private function mapModels():void {

		}

		// -----------------------
		// Services.
		// -----------------------

		private function mapServices():void {


		}

		// -----------------------
		// Singletons.
		// -----------------------

		private function mapSingletons():void {
			injector.map(TransitionSplashToHomeState).asSingleton();
			injector.map(HomeState).asSingleton();
			injector.map(CropState).asSingleton();
			injector.map(PaintState).asSingleton();
			injector.map(BookState).asSingleton();
			injector.map(TransitionHomeToPaintState).asSingleton();
		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapNotifications():void {
			injector.map(NotifyCanvasBackgroundSetSignal).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {
			_commandMap.map(RequestCreateCanvasBackgroundSignal).toCommand(CreateCanvasBackgroundCommand);
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {

		}
	}
}
