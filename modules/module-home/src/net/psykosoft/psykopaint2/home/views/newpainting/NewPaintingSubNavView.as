package net.psykosoft.psykopaint2.home.views.newpainting
{

	import flash.display.Bitmap;

	import net.psykosoft.psykopaint2.base.ui.components.list.ISnapListData;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.SbBitmapButton;
	import net.psykosoft.psykopaint2.core.views.components.button.SbIconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class NewPaintingSubNavView extends SubNavigationViewBase
	{
		public static const LBL_NEW:String = "Color Painting";
		public static const LBL_NEW_PHOTO:String = "Photo Painting";
		public static const LBL_CONTINUE:String = "Continue Painting";

		private var _dataProvider:Vector.<ISnapListData>;

		public function NewPaintingSubNavView() {
			super();
			id = "NewPaintingSubNavView";
		}

		override protected function onEnabled():void {
			setHeader( "" );

			_dataProvider = new Vector.<ISnapListData>();

			setRightButton( LBL_CONTINUE, ButtonIconType.CONTINUE );
		}

		public function createNewPaintingButtons():void {

			// New color painting button.
			createCenterButton( LBL_NEW, ButtonIconType.NEW_PAINTING_MANUAL, SbIconButton );

			// New photo painting button.
			createCenterButton( LBL_NEW_PHOTO, ButtonIconType.NEW_PAINTING_AUTO, SbIconButton );
		}

		public function createInProgressPaintings( data:Vector.<PaintingInfoVO> ):void {
			var numPaintings:uint = data.length;
			for( var i:uint = 0; i < numPaintings; i++ ) {
				var vo:PaintingInfoVO = data[ i ];
				var dump:Array = vo.id.split( "-" );
				var str:String = dump[ dump.length - 1 ];
				createCenterButton( str, null, SbBitmapButton, new Bitmap( vo.thumbnail ), true );
			}
		}

		/*public function validateCenterButtons():void {
			navigation.scroller.setDataProvider( _dataProvider );
		} */

		public function getIdForSelectedInProgressPainting():String {
			// TODO: complete navigation refactor
			return /*_buttonGroup.getSelectedBtnLabel()*/ "";
		}
	}
}
