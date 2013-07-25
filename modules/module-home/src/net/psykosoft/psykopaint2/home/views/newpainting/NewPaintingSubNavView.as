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

		public function NewPaintingSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "" );

			// TODO: complete navigation refactor
//			navigation.layout();
		}

		public function setInProgressPaintings( data:Vector.<PaintingInfoVO> ):void {

			var i:uint;
			var len:uint;

			var centerButtonDataProvider:Vector.<ISnapListData> = new Vector.<ISnapListData>();

			// New color painting button.
			createCenterButtonData( centerButtonDataProvider, LBL_NEW, ButtonIconType.NEW_PAINTING_MANUAL, SbIconButton );

			// New photo painting button.
			createCenterButtonData( centerButtonDataProvider, LBL_NEW_PHOTO, ButtonIconType.NEW_PAINTING_AUTO, SbIconButton );

			// Old painting buttons.
			len = data.length;
			for( i = 0; i < len; i++ ) {

				var vo:PaintingInfoVO = data[ i ];
				var dump:Array = vo.id.split( "-" );
				var str:String = dump[ dump.length - 1 ];

				createCenterButtonData( centerButtonDataProvider, str, null, SbBitmapButton, new Bitmap( vo.thumbnail ) );
			}

			_scroller.setDataProvider( centerButtonDataProvider );

			// TODO: complete navigation refactor
//			if( lastSelectedPaintingLabel == "" ) _buttonGroup.setSelectedButtonByIndex( 0 );
//			else _buttonGroup.setSelectedButtonByLabel( lastSelectedPaintingLabel );
//			navigation.addCenterButtonGroup( _buttonGroup );

			// Show right button.
			if( !HomeSettings.isStandalone ) {
				navigation.setRightButton( LBL_CONTINUE, ButtonIconType.CONTINUE );
			}
		}

		public function getIdForSelectedInProgressPainting():String {
			// TODO: complete navigation refactor
			return /*_buttonGroup.getSelectedBtnLabel()*/ "";
		}
	}
}
