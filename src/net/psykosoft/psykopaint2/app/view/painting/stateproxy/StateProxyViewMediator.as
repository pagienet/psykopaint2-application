package net.psykosoft.psykopaint2.app.view.painting.stateproxy
{

	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateUpdateFromModuleActivationSignal;
	import net.psykosoft.psykopaint2.app.view.base.StarlingMediatorBase;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.signals.NotifyModuleActivatedSignal;

	public class StateProxyViewMediator extends StarlingMediatorBase
	{
		[Inject]
		public var notifyModuleActivatedSignal:NotifyModuleActivatedSignal;

		[Inject]
		public var requestStateUpdateFromModuleActivationSignal:RequestStateUpdateFromModuleActivationSignal;

		override public function initialize():void {

			super.initialize();
			manageMemoryWarnings = false;
			manageStateChanges = false;

			notifyModuleActivatedSignal.add( onModuleActivated );
		}

		private function onModuleActivated( vo:ModuleActivationVO ):void {
			requestStateUpdateFromModuleActivationSignal.dispatch( vo );
		}
	}
}
