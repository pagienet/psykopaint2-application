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
		public static const ID_NEW:String = "Color Painting";
		public static const ID_NEW_PHOTO:String = "Photo Painting";
		public static const ID_CONTINUE:String = "Continue Painting";

		public function NewPaintingSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
			setRightButton( ID_CONTINUE, ButtonIconType.CONTINUE );
		}

		public function createNewPaintingButtons():void {
			createCenterButton( ID_NEW, ID_NEW, ButtonIconType.NEW_PAINTING_MANUAL, SbIconButton );
			createCenterButton( ID_NEW_PHOTO, ID_NEW_PHOTO, ButtonIconType.NEW_PAINTING_AUTO, SbIconButton );
		}

		public function createInProgressPaintings( data:Vector.<PaintingInfoVO> ):void {
			var numPaintings:uint = data.length;
			for( var i:uint = 0; i < numPaintings; i++ ) {
				var vo:PaintingInfoVO = data[ i ];
				var dump:Array = vo.id.split( "-" );
				var str:String = dump[ dump.length - 1 ];
				createCenterButton( str, str, null, SbBitmapButton, new Bitmap( vo.thumbnail ), true );
			}
		}
	}
}
