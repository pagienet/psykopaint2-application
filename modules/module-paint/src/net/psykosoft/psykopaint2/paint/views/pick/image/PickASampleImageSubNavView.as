package net.psykosoft.psykopaint2.paint.views.pick.image
{

	import flash.display.Bitmap;

	import net.psykosoft.psykopaint2.base.ui.components.ButtonGroup;
	import net.psykosoft.psykopaint2.base.utils.data.BitmapAtlas;
	import net.psykosoft.psykopaint2.core.views.components.button.ButtonLabelType;
	import net.psykosoft.psykopaint2.core.views.components.button.SbButton;
	import net.psykosoft.psykopaint2.core.views.navigation.SubNavigationViewBase;

	public class PickASampleImageSubNavView extends SubNavigationViewBase
	{
		public static const LBL_BACK:String = "Pick an Image";

		private var _atlas:BitmapAtlas;
		private var _group:ButtonGroup;

		public function PickASampleImageSubNavView() {
			super();
		}

		override protected function onEnabled():void {
			navigation.setHeader( "Pick a sample image" );
			navigation.setLeftButton( LBL_BACK );
			navigation.layout();
		}

		override protected function onDisabled():void {
			if( _atlas ) _atlas.dispose();
		}

		public function setImages( atlas:BitmapAtlas ):void {
			_atlas = atlas;
			_group = new ButtonGroup();
			var names:Vector.<String> = atlas.names;
			for( var i:uint; i < names.length; i++ ) {
				var name:String = names[ i ];
				var btn:SbButton = navigation.createButton( name, "", ButtonLabelType.CENTER, new Bitmap( atlas.getSubTextureForId( name ) ) );
				_group.addButton( btn );
			}
			navigation.addCenterButtonGroup( _group );
			navigation.layout();
		}
	}
}
