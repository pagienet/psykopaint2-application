package net.psykosoft.psykopaint2.core.views.base
{

	import flash.display.DisplayObjectContainer;

	import net.psykosoft.psykopaint2.core.signals.RequestAddViewToMainLayerSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestInteractionBlockSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class CoreRootViewMediator extends Mediator
	{
		[Inject]
		public var view:CoreRootView;

		[Inject]
		public var requestInteractionBlockSignal:RequestInteractionBlockSignal;

		[Inject]
		public var requestAddViewToMainLayerSignal:RequestAddViewToMainLayerSignal;

		override public function initialize():void {

			// From app.
			requestInteractionBlockSignal.add( onInteractionBlockRequest );
			requestAddViewToMainLayerSignal.add( onRequestToAddViewToMainLayer );
		}

		private function onRequestToAddViewToMainLayer( child:DisplayObjectContainer ):void {
			view.addToMainLayer( child );
		}

		private function onInteractionBlockRequest( block:Boolean ):void {
			view.showBlocker( block );
		}
	}
}
