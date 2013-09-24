package net.psykosoft.psykopaint2.home.views.newpainting
{

	import flash.display.Bitmap;

	import net.psykosoft.psykopaint2.core.data.PaintingInfoVO;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonIconType;
	import net.psykosoft.psykopaint2.core.views.components.button.BitmapButton;
	import net.psykosoft.psykopaint2.core.views.components.button.IconButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class NewPaintingSubNavView extends SubNavigationViewBase
	{
		public static const ID_NEW:String = "Color Painting";
		public static const ID_NEW_PHOTO:String = "Photo Painting";
		public static const ID_CONTINUE:String = "Continue Painting";

		private var _disabledId:String;
		private var _rightButtonIsHidden:Boolean;

		public function NewPaintingSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			setHeader( "" );
			setRightButton( ID_CONTINUE, ID_CONTINUE, ButtonIconType.CONTINUE );
			if( _rightButtonIsHidden ) {
				_rightButtonIsHidden = false;
				showRightButton( false );
			}
		}

		public function createNewPaintingButtons():void {
			createCenterButton( ID_NEW, ID_NEW, ButtonIconType.NEW_PAINTING_MANUAL, IconButton );
			createCenterButton( ID_NEW_PHOTO, ID_NEW_PHOTO, ButtonIconType.NEW_PAINTING_AUTO, IconButton );
		}

		public function createInProgressPaintings( data:Vector.<PaintingInfoVO>, unavailablePaintingId:String ):void {
			_disabledId = unavailablePaintingId;
			var numPaintings:uint = data.length;
			for( var i:uint = 0; i < numPaintings; i++ ) {
				var vo:PaintingInfoVO = data[ i ];
				var dump:Array = vo.id.split( "-" );
				var str:String = dump[ dump.length - 1 ];
				var btnIsEnabled:Boolean = vo.id != unavailablePaintingId;
				if( !btnIsEnabled ) {
					_rightButtonIsHidden = true;
					showRightButton( false );
				}
				createCenterButton( str, str, null, BitmapButton, new Bitmap( vo.thumbnail ), true, btnIsEnabled );
			}
		}

		public function enableDisabledButtons():void {
			enableButtonWithId( _disabledId, true );
		}
	}
}
