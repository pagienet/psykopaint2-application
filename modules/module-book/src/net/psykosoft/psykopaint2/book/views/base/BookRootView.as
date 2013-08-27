package net.psykosoft.psykopaint2.book.views.base
{

	import flash.display.Sprite;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.book.views.book.BookSubNavView;
	import net.psykosoft.psykopaint2.book.views.book.BookView;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;

	import org.osflash.signals.Signal;

	public class BookRootView extends Sprite
	{
		public var onSubViewsReady:Signal;
		private var _bookView:BookView;
		private var _bookReady:Boolean;

		public function BookRootView() {
			super();

			onSubViewsReady = new Signal();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );

			// Add main views.
			addChild( _bookView = new BookView() );
			_bookView.addEventListener( Event.ADDED_TO_STAGE, onBookViewAddedToStage );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.BOOK, BookSubNavView );
		}

		private function onBookViewAddedToStage( event:Event ):void {
			_bookView.removeEventListener( Event.ADDED_TO_STAGE, onBookViewAddedToStage );
			_bookReady = true;
			checkReady();
		}

		private function onAddedToStage( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			checkReady();
		}

		public function checkReady():void {
			if( stage && _bookReady )
				onSubViewsReady.dispatch();
		}

		public function dispose():void {
			_bookView.dispose();
			removeChild( _bookView );
		}
	}
}
