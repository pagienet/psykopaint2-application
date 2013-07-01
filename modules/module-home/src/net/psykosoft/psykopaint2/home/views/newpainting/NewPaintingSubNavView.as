package net.psykosoft.psykopaint2.home.views.newpainting
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.ui.components.ButtonGroup;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;

	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonLabelType;
	import net.psykosoft.psykopaint2.core.views.components.button.SbButton;
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

			navigation.setHeader( "New Painting" );



			if( !HomeSettings.isStandalone ) {
				navigation.setRightButton( LBL_CONTINUE );
			}

			navigation.addCenterButton( LBL_NEW, ButtonIconType.NEW, ButtonLabelType.NONE );
//			setButtonWithLabelSelectable ( LBL_NEW, false );

			navigation.layout();
		}

		public function setInProgressPaintings( data:Vector.<PaintingVO> ):void {
			if( !data ) return;
			var len:uint = data.length;
			var group:ButtonGroup = new ButtonGroup();
			for( var i:uint; i < len; i++ ) {
				var vo:PaintingVO = data[ i ];
				var bmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( vo.colorImageARGB, vo.width, vo.height );
				bmd = BitmapDataUtils.scaleBitmapData( bmd, 0.25 ); // TODO: scale differently depending on file resolution and display resolution
				var btn:SbButton = navigation.createButton( vo.id, ButtonIconType.DEFAULT, ButtonLabelType.CENTER, new Bitmap( bmd ) );
				group.addButton( btn );
			}
			group.setSelectedButtonByIndex( group.numButtons - 1 );
			navigation.addCenterButtonGroup( group );
			navigation.layout();
		}
	}
}
