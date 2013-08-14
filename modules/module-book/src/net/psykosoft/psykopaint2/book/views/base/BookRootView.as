package net.psykosoft.psykopaint2.book.views.base
{

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.book.views.book.BookView;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	import org.osflash.signals.Signal;

	public class BookRootView extends Sprite
	{
		public var onSubViewsReady : Signal;
		private var _bookView : BookView;
		private var _subViewsReady : Boolean;

		public function BookRootView(imageSource : String) {
			super();

			onSubViewsReady = new Signal();

			// Add main views.
			addChild( _bookView = new BookView() );

			_bookView
			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.BOOK_PICK_SAMPLE_IMAGE, SubNavigationViewBase );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.BOOK_PICK_USER_IMAGE_IOS, SubNavigationViewBase );

			// TODO: move this block to where all views are really ready; assets loaded etc etc
			{
				_subViewsReady = true;
				notifyIfReady();
			}

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
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
