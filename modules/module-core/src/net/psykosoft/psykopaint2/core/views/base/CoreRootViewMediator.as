package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.DisplayObjectContainer;

	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class CoreRootViewMediator extends Mediator
	{
		[Inject]
		public var view:CoreRootView;

		// TODO: Should probably do this through set-up command
		[Inject]
		public var requestAddViewToMainLayerSignal:RequestAddViewToMainLayerSignal;

		override public function initialize():void {

			// From app.
			requestAddViewToMainLayerSignal.add( onRequestToAddViewToMainLayer );
		}

		private function onRequestToAddViewToMainLayer( child:DisplayObjectContainer ):void {
			view.addToMainLayer( child );
		}
	}
}
