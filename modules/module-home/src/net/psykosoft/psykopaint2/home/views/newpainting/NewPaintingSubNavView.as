package net.psykosoft.psykopaint2.home.views.newpainting
{

	import flash.display.Bitmap;

	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;
	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.SbBitmapButton;
	import net.psykosoft.psykopaint2.core.views.components.button.SbIconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.home.config.HomeSettings;

	public class NewPaintingSubNavView extends SubNavigationViewBase
	{
		public static const LBL_NEW:String = "Color Painting";
		public static const LBL_NEW_PHOTO:String = "Photo Painting";
		public static const LBL_CONTINUE:String = "Continue Painting";

		private var _dataProvider:Vector.<ISnapListData>;

		public function NewPaintingSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "" );

			_dataProvider = new Vector.<ISnapListData>();

			// New color painting button.
			navigation.createCenterButtonData( _dataProvider, LBL_NEW, ButtonIconType.NEW_PAINTING_MANUAL, SbIconButton );

			// New photo painting button.
			navigation.createCenterButtonData( _dataProvider, LBL_NEW_PHOTO, ButtonIconType.NEW_PAINTING_AUTO, SbIconButton );

			// Show right button.
			if( !HomeSettings.isStandalone ) {
				navigation.setRightButton( LBL_CONTINUE, ButtonIconType.CONTINUE );
			}
		}

		public function setInProgressPaintings( data:Vector.<PaintingInfoVO> ):void {

			var i:uint;
			var len:uint;

			// Old painting buttons.
			len = data.length;
			for( i = 0; i < len; i++ ) {

				var vo:PaintingInfoVO = data[ i ];
				var dump:Array = vo.id.split( "-" );
				var str:String = dump[ dump.length - 1 ];

				navigation.createCenterButtonData( _dataProvider, str, null, SbBitmapButton, new Bitmap( vo.thumbnail ) );
			}
		}

		public function validateCenterButtons():void {
			navigation.scroller.setDataProvider( _dataProvider );
		}

		public function getIdForSelectedInProgressPainting():String {
			// TODO: complete navigation refactor
			return /*_buttonGroup.getSelectedBtnLabel()*/ "";
		}
	}
}
