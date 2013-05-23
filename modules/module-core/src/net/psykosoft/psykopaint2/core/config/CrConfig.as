package net.psykosoft.psykopaint2.core.config
{

	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.Stage3D;

	import net.psykosoft.psykopaint2.base.robotlegs.BsSignalCommandMapBundle;
	import net.psykosoft.psykopaint2.core.commands.CrChangeStateCommand;
	import net.psykosoft.psykopaint2.core.managers.gestures.CrGestureManager;
	import net.psykosoft.psykopaint2.core.models.CrStateModel;
	import net.psykosoft.psykopaint2.core.signals.notifications.CrNotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.notifications.CrNotifyNavigationToggledSignal;
	import net.psykosoft.psykopaint2.core.signals.notifications.CrNotifyStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.requests.CrRequestStateChangeSignal;
	import net.psykosoft.psykopaint2.core.views.base.CrRootView;
	import net.psykosoft.psykopaint2.core.views.base.CrRootViewMediator;
	import net.psykosoft.psykopaint2.core.views.navigation.CrNavigationViewMediator;
	import net.psykosoft.psykopaint2.core.views.navigation.CrSbNavigationView;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;

	public class CrConfig
	{
		private var _stage:Stage;
		private var _stage3d:Stage3D;
		private var _injector:Injector;
		private var _mediatorMap:IMediatorMap;
		private var _commandMap:ISignalCommandMap;

		public function CrConfig( display:DisplayObjectContainer, stage:Stage, stage3d:Stage3D ) {
			super();

			var context:IContext = new Context();
			context.install( MVCSBundle, BsSignalCommandMapBundle );
			context.configure( new ContextView( display ) );

			_injector = context.injector;
			_mediatorMap = _injector.getInstance( IMediatorMap );
			_commandMap = _injector.getInstance( ISignalCommandMap );

			_stage = stage;
			_stage3d = stage3d;

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
			_injector.map( CrStateModel ).asSingleton();
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
			_injector.map( Stage ).toValue( _stage );
			_injector.map( Stage3D ).toValue( _stage3d );
			_injector.map( CrGestureManager ).asSingleton();
		}

		// -----------------------
		// Notifications.
		// -----------------------

		private function mapNotifications():void {
			_injector.map( CrNotifyStateChangeSignal ).asSingleton();
			_injector.map( CrNotifyGlobalGestureSignal ).asSingleton();
			_injector.map( CrNotifyNavigationToggledSignal ).asSingleton();
		}

		// -----------------------
		// Commands.
		// -----------------------

		private function mapCommands():void {
			_commandMap.map( CrRequestStateChangeSignal ).toCommand( CrChangeStateCommand );
		}

		// -----------------------
		// View mediators.
		// -----------------------

		private function mapMediators():void {
			_mediatorMap.map( CrRootView ).toMediator( CrRootViewMediator );
			_mediatorMap.map( CrSbNavigationView ).toMediator( CrNavigationViewMediator );
		}
	}
}
