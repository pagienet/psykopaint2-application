package net.psykosoft.psykopaint2.home.views.home
{

	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;

	public class NewPaintingSubNavView extends SubNavigationViewBase
	{
		public static const LBL_PAINT:String = "Start";

		public function NewPaintingSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "New Painting" );

			if( !HomeSettings.isStandalone ) {
				addCenterButton( LBL_PAINT );
			}

			invalidateContent();
		}
	}
}
