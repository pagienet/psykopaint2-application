package net.psykosoft.psykopaint2.home.views.base
{

	import net.psykosoft.psykopaint2.home.signals.RequestHomeRootViewRemovalSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class HomeRootViewMediator extends Mediator
	{
		[Inject]
		public var view:HomeRootView;

		[Inject]
		public var requestHomeRootViewRemovalSignal:RequestHomeRootViewRemovalSignal;

		override public function initialize():void {

			// From app.
			requestHomeRootViewRemovalSignal.add( onRemovalRequest );
		}

		override public function destroy():void {
			requestHomeRootViewRemovalSignal.remove( onRemovalRequest );
		}

		private function onRemovalRequest():void {
			view.dispose();
			view.parent.removeChild( view );
		}
	}
}
