package net.psykosoft.psykopaint2.book.views.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.book.views.book.BookView;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.navigation.StateToSubNavLinker;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class BookRootView extends Sprite
	{
		public function BookRootView() {
			super();

			// Add main views.
			addChild( new BookView() );

			// Link sub-navigation views that are created dynamically by CrNavigationView
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.BOOK_PICK_SAMPLE_IMAGE, SubNavigationViewBase );
			StateToSubNavLinker.linkSubNavToState( NavigationStateType.BOOK_PICK_USER_IMAGE_IOS, SubNavigationViewBase );
		}
	}
}
