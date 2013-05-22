package net.psykosoft.psykopaint2.core.config
{

	import flash.display.DisplayObjectContainer;

	import net.psykosoft.psykopaint2.base.robotlegs.BsSignalCommandMapBundle;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;

	public class CrConfig
	{
		private var _injector:Injector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function CrConfig( display:DisplayObjectContainer ) {
			super();

			var context:IContext = new Context();
			context.install( MVCSBundle, BsSignalCommandMapBundle );
			context.configure( new ContextView( display ) );

			_injector = context.injector;
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

		}
	}
}
