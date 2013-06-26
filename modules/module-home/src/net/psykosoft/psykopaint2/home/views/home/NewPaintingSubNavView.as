package net.psykosoft.psykopaint2.home.views.home
{

	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;

	public class NewPaintingSubNavView extends SubNavigationViewBase
	{
		public static const LBL_NEW:String = "New Painting";
		public static const LBL_CONTINUE:String = "Continue Painting";

		public function NewPaintingSubNavView() {
			super();
		}

		override protected function onEnabled():void {

			setLabel( "New Painting" );

			if( !HomeSettings.isStandalone ) {
				setRightButton( LBL_CONTINUE );
				addCenterButton( LBL_NEW );
			}

			invalidateContent();
		}

		public function setInProgressPaintings( data:Vector.<PaintingVO> ):void {

		}
	}
}
