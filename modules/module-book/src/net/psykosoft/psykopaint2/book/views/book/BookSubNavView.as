package net.psykosoft.psykopaint2.book.views.book
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class BookSubNavView extends SubNavigationViewBase
	{
		public static const ID_BACK:String = "Back";

		public function BookSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "Sup y'all" );
			setLeftButton( ID_BACK, ID_BACK );
		}
	}
}
