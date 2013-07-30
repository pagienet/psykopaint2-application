package net.psykosoft.psykopaint2.core.views.navigation
{

	public class EmptySubNavView extends SubNavigationViewBase
	{
		public function EmptySubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
		}
	}
}
