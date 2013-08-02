package net.psykosoft.psykopaint2.book.views.book
{

	import net.psykosoft.psykopaint2.core.models.StateType;
	import net.psykosoft.psykopaint2.core.views.base.MediatorBase;

	public class BookViewMediator extends MediatorBase
	{
		[Inject]
		public var view:BookView;

		override public function initialize():void {

			// Init.
			registerView( view );
			super.initialize();
			registerEnablingState( StateType.BOOK_STANDALONE );
			registerEnablingState( StateType.BOOK_PICK_SAMPLE_IMAGE );
			registerEnablingState( StateType.BOOK_PICK_USER_IMAGE_IOS );
		}
	}
}
