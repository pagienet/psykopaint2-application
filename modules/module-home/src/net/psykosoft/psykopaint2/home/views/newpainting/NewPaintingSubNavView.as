package net.psykosoft.psykopaint2.home.views.newpainting
{

	import flash.display.Bitmap;

	import net.psykosoft.psykopaint2.base.ui.components.ButtonGroup;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
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

		static public var lastSelectedPaintingLabel:String = "";
		static public var lastScrollerPosition:Number = 0;

		public function NewPaintingSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "New Painting" );
			navigation.addCenterButton( LBL_NEW, ButtonIconType.NEW, ButtonLabelType.NONE );
			navigation.layout();
		}

		public function setInProgressPaintings( data:Vector.<PaintingInfoVO> ):String {
			var len:uint = data.length;
			_buttonGroup = new ButtonGroup();
			for( var i:uint; i < len; i++ ) {
				var vo:PaintingInfoVO = data[ i ];
				var dump:Array = vo.id.split( "-" );
				var str:String = dump[ dump.length - 1 ];
				var btn:SbButton = navigation.createButton( str, ButtonIconType.POLAROID, ButtonLabelType.NO_BACKGROUND, new Bitmap( vo.thumbnail ) );
				_buttonGroup.addButton( btn );
			}
			if( lastSelectedPaintingLabel == "" ) _buttonGroup.setSelectedButtonByIndex( 0 );
			else _buttonGroup.setSelectedButtonByLabel( lastSelectedPaintingLabel );
			navigation.addCenterButtonGroup( _buttonGroup );

			// Show right button.
			if( !HomeSettings.isStandalone ) {
				navigation.setRightButton( LBL_CONTINUE, ButtonIconType.CONTINUE );
			}

			navigation.layout();

			return btn.labelText;
		}

		public function getIdForSelectedInProgressPainting():String {
			return _buttonGroup.getSelectedBtnLabel();
		}
	}
}
