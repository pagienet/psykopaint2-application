package net.psykosoft.psykopaint2.home.views.newpainting
{

	import flash.display.Bitmap;

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

		public function NewPaintingSubNavView() {
			super();
			id = "NewPaintingSubNavView";
		}

		override protected function onEnabled():void {
			setHeader( "" );
			setRightButton( LBL_CONTINUE, ButtonIconType.CONTINUE );
		}

		public function setInProgressPaintings( data:Vector.<PaintingInfoVO> ):void {

			var i:uint;
			var len:uint;

			// New color painting button.
			createCenterButton( LBL_NEW, ButtonIconType.NEW_PAINTING_MANUAL, SbIconButton );

			// New photo painting button.
			createCenterButton( LBL_NEW_PHOTO, ButtonIconType.NEW_PAINTING_AUTO, SbIconButton );

			// Old painting buttons.
			len = data.length;
			for( i = 0; i < len; i++ ) {

				var vo:PaintingInfoVO = data[ i ];
				var dump:Array = vo.id.split( "-" );
				var str:String = dump[ dump.length - 1 ];

				createCenterButton( str, null, SbBitmapButton, new Bitmap( vo.thumbnail ) );
			}

			validateCenterButtons();

			// TODO: complete navigation refactor
//			if( lastSelectedPaintingLabel == "" ) _buttonGroup.setSelectedButtonByIndex( 0 );
//			else _buttonGroup.setSelectedButtonByLabel( lastSelectedPaintingLabel );
//			navigation.addCenterButtonGroup( _buttonGroup );
		}

		public function getIdForSelectedInProgressPainting():String {
			// TODO: complete navigation refactor
			return /*_buttonGroup.getSelectedBtnLabel()*/ "";
		}
	}
}
