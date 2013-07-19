package net.psykosoft.psykopaint2.book.views.base
{

	import net.psykosoft.psykopaint2.base.ui.base.RootViewBase;
	import net.psykosoft.psykopaint2.book.views.book.BookView;
	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.navigation.EmptySubNavView;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class BookRootView extends RootViewBase
	{
		public function BookRootView() {
			super();

			// Add main views.
			addRegisteredView( new BookView(), this );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( StateType.BOOK_PICK_SAMPLE_IMAGE, SubNavigationViewBase );
			StateToSubNavLinker.linkSubNavToState( StateType.BOOK_PICK_USER_IMAGE_IOS, SubNavigationViewBase );
		}
	}
}
