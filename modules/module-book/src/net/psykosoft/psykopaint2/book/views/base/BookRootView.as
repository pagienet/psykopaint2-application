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
		public var onSubViewsReady : Signal;
		private var _bookView : BookView;
		private var _subViewsReady : Boolean;

		public function BookRootView() {
			super();

			onSubViewsReady = new Signal();

			// Add main views.
			addChild( _bookView = new BookView() );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.BOOK, BookSubNavView );

			// TODO: move this block to where all views are really ready; assets loaded etc etc
			{
				_subViewsReady = true;
				notifyIfReady();
			}

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, -5000);
		}

		private function onAddedToStage(event : Event) : void
		{
			notifyIfReady();
		}

		private function notifyIfReady() : void
		{
			if (stage != null && _subViewsReady)
				onSubViewsReady.dispatch();
		}

		public function dispose() : void
		{
			_bookView.dispose();
			removeChild(_bookView);
		}
	}
}
