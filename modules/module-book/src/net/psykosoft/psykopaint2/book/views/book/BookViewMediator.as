package net.psykosoft.psykopaint2.book.views.book
{

	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class BookViewMediator extends MediatorBase
	{
		[Inject]
		public var view:BookView;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();

			registerEnablingState( NavigationStateType.BOOK_STANDALONE );
			registerEnablingState( NavigationStateType.BOOK_PICK_SAMPLE_IMAGE );
			registerEnablingState( NavigationStateType.BOOK_PICK_USER_IMAGE_IOS );
		}
	}
}
