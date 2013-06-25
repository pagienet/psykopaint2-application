package net.psykosoft.psykopaint2.home.views.home
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;

	public class ContinuePaintingSubNavView extends SubNavigationViewBase
	{
		public static const LBL_CONTINUE:String = "Continue";
		public static const LBL_DELETE:String = "Delete";

		public function ContinuePaintingSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "Continue Painting" );

			if( !HomeSettings.isStandalone ) {
				addCenterButton( LBL_CONTINUE );
			}
			addCenterButton( LBL_DELETE );

			invalidateContent();
		}
	}
}
