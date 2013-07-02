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

		private var _buttonGroup:ButtonGroup;

		public function NewPaintingSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "New Painting" );
			navigation.addCenterButton( LBL_NEW, ButtonIconType.NEW, ButtonLabelType.NONE );
			navigation.layout();
		}

		public function setInProgressPaintings( data:Vector.<PaintingVO> ):String {
			var len:uint = data.length;
			_buttonGroup = new ButtonGroup();
			for( var i:uint; i < len; i++ ) {
				var vo:PaintingVO = data[ i ];
				var bmd:BitmapData = BitmapDataUtils.getBitmapDataFromBytes( vo.colorImageARGB, vo.width, vo.height, true );
				bmd = BitmapDataUtils.scaleBitmapData( bmd, 0.25 ); // TODO: scale differently depending on file resolution and display resolution
				var btn:SbButton = navigation.createButton( vo.id, ButtonIconType.DEFAULT, ButtonLabelType.CENTER, new Bitmap( bmd ) );
				_buttonGroup.addButton( btn );
			}
			_buttonGroup.setSelectedButtonByIndex( _buttonGroup.numButtons - 1 );
			navigation.addCenterButtonGroup( _buttonGroup );
			navigation.layout();

			// Show right button.
			if( !HomeSettings.isStandalone ) {
				navigation.setRightButton( LBL_CONTINUE );
			}

			return btn.labelText;
		}

		public function getIdForSelectedInProgressPainting():String {
			return _buttonGroup.getSelectedBtnLabel();
		}
	}
}
