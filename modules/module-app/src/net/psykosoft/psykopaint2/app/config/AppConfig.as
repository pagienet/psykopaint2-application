package net.psykosoft.psykopaint2.app.config
{
	import net.psykosoft.psykopaint2.app.commands.CreateCanvasBackgroundCommand;
	import net.psykosoft.psykopaint2.app.commands.CreateCropBackgroundCommand;
	import net.psykosoft.psykopaint2.app.signals.NotifyFrozenBackgroundCreatedSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreateCanvasBackgroundSignal;
	import net.psykosoft.psykopaint2.app.signals.RequestCreateCropBackgroundSignal;
	import net.psykosoft.psykopaint2.app.states.BookLayer;
	import net.psykosoft.psykopaint2.app.states.CropState;
	import net.psykosoft.psykopaint2.app.states.HomeState;
	import net.psykosoft.psykopaint2.app.states.TransitionBookToCropState;
	import net.psykosoft.psykopaint2.app.states.TransitionCropToHomeState;
	import net.psykosoft.psykopaint2.app.states.TransitionCropToPaintState;
	import net.psykosoft.psykopaint2.app.states.TransitionHomeToCropState;
	import net.psykosoft.psykopaint2.app.states.TransitionPaintToHomeState;
	import net.psykosoft.psykopaint2.app.states.TransitionSplashToHomeState;
	import net.psykosoft.psykopaint2.app.states.PaintState;
	import net.psykosoft.psykopaint2.app.states.TransitionHomeToPaintState;

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
			mapSignals();
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
			injector.map(BookLayer).asSingleton();
			injector.map(HomeState).asSingleton();
			injector.map(CropState).asSingleton();
			injector.map(PaintState).asSingleton();
			injector.map(TransitionHomeToPaintState).asSingleton();
			injector.map(TransitionHomeToCropState).asSingleton();
			injector.map(TransitionCropToPaintState).asSingleton();
			injector.map(TransitionCropToHomeState).asSingleton();
			injector.map(TransitionPaintToHomeState).asSingleton();
			injector.map(TransitionBookToCropState).asSingleton();
		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapSignals():void {
			injector.map(NotifyFrozenBackgroundCreatedSignal).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {
			_commandMap.map(RequestCreateCanvasBackgroundSignal).toCommand(CreateCanvasBackgroundCommand);
			_commandMap.map(RequestCreateCropBackgroundSignal).toCommand(CreateCropBackgroundCommand);
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {

		}
	}
}
