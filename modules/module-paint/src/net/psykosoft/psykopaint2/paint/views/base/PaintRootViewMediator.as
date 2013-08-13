package net.psykosoft.psykopaint2.paint.views.base
{

	import net.psykosoft.psykopaint2.paint.signals.RequestPaintRootViewRemovalSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class PaintRootViewMediator extends Mediator
	{
		[Inject]
		public var view:PaintRootView;

		[Inject]
		public var requestPaintRootViewRemovalSignal:RequestPaintRootViewRemovalSignal;

		override public function initialize():void {

			// From app.
			requestPaintRootViewRemovalSignal.add( onRemovalRequest );
		}

		override public function destroy():void {
			requestPaintRootViewRemovalSignal.remove( onRemovalRequest );
		}

		private function onRemovalRequest():void {
			view.dispose();
			view.parent.removeChild( view );
		}
	}
}
