package net.psykosoft.psykopaint2.home.config
{

	import away3d.containers.View3D;

	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavView;
	import net.psykosoft.psykopaint2.home.views.home.HomeSubNavViewMediator;
	import net.psykosoft.psykopaint2.home.views.home.HomeView;
	import net.psykosoft.psykopaint2.home.views.home.HomeViewMediator;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;

	public class HomeConfig
	{
		private var _injector:Injector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function HomeConfig( injector:Injector ) {
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

		public function get injector():Injector {
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

		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapNotifications():void {

		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {

		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			_mediatorMap.map( HomeView ).toMediator( HomeViewMediator );
			_mediatorMap.map( HomeSubNavView ).toMediator( HomeSubNavViewMediator );
		}
	}
}
