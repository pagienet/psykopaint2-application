package net.psykosoft.psykopaint2.book.views.base
{
	import net.psykosoft.psykopaint2.book.signals.RequestBookRootViewRemovalSignal;

	import robotlegs.bender.bundles.mvcs.Mediator;

	public class BookRootViewMediator extends Mediator
	{
		[Inject]
		public var view:BookRootView;

		[Inject]
		public var requestBookRootViewRemovalSignal:RequestBookRootViewRemovalSignal;

		public function BookRootViewMediator()
		{
		}

		override public function initialize():void {

			// From app.
			requestBookRootViewRemovalSignal.add( onRemovalRequest );

			view.init();
		}

		override public function destroy():void {
			requestBookRootViewRemovalSignal.remove( onRemovalRequest );
		}

		private function onRemovalRequest():void {
			view.dispose();
			view.parent.removeChild( view );
		}
	}
}
