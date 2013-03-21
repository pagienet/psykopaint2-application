package net.psykosoft.psykopaint2.app.view.painting.stateproxy
{

	import net.psykosoft.psykopaint2.app.signal.requests.RequestStateUpdateFromModuleActivationSignal;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleActivationVO;
	import net.psykosoft.psykopaint2.core.signals.NotifyModuleActivatedSignal;

	import robotlegs.extensions.starlingViewMap.impl.StarlingMediator;

	public class StateProxyViewMediator extends StarlingMediator
	{
		[Inject]
		public var notifyModuleActivatedSignal:NotifyModuleActivatedSignal;

		[Inject]
		public var requestStateUpdateFromModuleActivationSignal:RequestStateUpdateFromModuleActivationSignal;

		override public function initialize():void {
			notifyModuleActivatedSignal.add( onModuleActivated );
		}

		private function onModuleActivated( vo:ModuleActivationVO ):void {
			requestStateUpdateFromModuleActivationSignal.dispatch( vo );
		}
	}
}
