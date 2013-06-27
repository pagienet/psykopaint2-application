package net.psykosoft.psykopaint2.home.views.newpainting
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;

	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonLabelType;
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

			areButtonsSelectable( true );

			if( !HomeSettings.isStandalone ) {
				setRightButton( LBL_CONTINUE );
				addCenterButton( LBL_NEW );
			}

			invalidateContent();
		}

		public function setInProgressPaintings( data:Vector.<PaintingVO> ):void {
			if( !data ) return;
			var len:uint = data.length;
			for( var i:uint; i < len; i++ ) {
				var vo:PaintingVO = data[ i ];
				var bmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( vo.colorImageARGB, vo.width, vo.height );
				bmd = BitmapDataUtils.scaleBitmapData( bmd, 0.25 ); // TODO: scale differently depending on file resolution and display resolution
				addCenterButton( vo.id, ButtonIconType.DEFAULT, ButtonLabelType.CENTER, new Bitmap( bmd ) );
			}
			invalidateContent();
		}
	}
}
