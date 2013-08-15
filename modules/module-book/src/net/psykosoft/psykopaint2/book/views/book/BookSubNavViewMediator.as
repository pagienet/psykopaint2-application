package net.psykosoft.psykopaint2.book.views.book
{

	import net.psykosoft.psykopaint2.book.signals.RequestExitBookSignal;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationMediatorBase;

	public class BookSubNavViewMediator extends SubNavigationMediatorBase
	{
		[Inject]
		public var view:BookSubNavView;

		[Inject]
		public var requestExitBookSignal:RequestExitBookSignal;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

		}

		override protected function onButtonClicked( id:String ):void {
			switch( id ) {

				case BookSubNavView.ID_BACK:
					requestExitBookSignal.dispatch();
					break;
			}
		}
	}
}
