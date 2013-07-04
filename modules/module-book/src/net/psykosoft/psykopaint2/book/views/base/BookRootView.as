package net.psykosoft.psykopaint2.book.views.base
{

	import net.psykosoft.psykopaint2.base.ui.base.RootViewBase;
	import net.psykosoft.psykopaint2.book.views.book.BookView;

	public class BookRootView extends RootViewBase
	{
		public function BookRootView() {
			super();

			// Add main views.
			addRegisteredView( new BookView(), this );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			// TODO: will this module have any sub navs?
		}
	}
}
