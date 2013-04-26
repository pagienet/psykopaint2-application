package net.psykosoft.psykopaint2.app.view.settings
{

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;

	import starling.textures.Texture;

	import starling.textures.TextureAtlas;

	public class SelectWallpaperSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK:String = "Back";

		private var _bmd:BitmapData;
		private var _atlas:TextureAtlas;

		public function SelectWallpaperSubNavigationView() {
			super( "Pick a Wallpaper" );
		}

		override protected function onEnabled():void {
			super.onEnabled();
			setLeftButton( "FooterIconsSettings",BUTTON_LABEL_BACK );
		}

		override protected function onDispose():void {

			if( _atlas ) {
				_atlas.dispose();
				_atlas = null;
			}

			if( _bmd ) {
				_bmd.dispose();
				_bmd = null;
			}

		}

		public function setImages( bmd:BitmapData, atlas:TextureAtlas ):void {

			_bmd = bmd;
			_atlas = atlas;

			// TODO: apply thumbnail skin to buttons

			var names:Vector.<String> = atlas.getNames();
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			for( var i:uint; i < names.length; i++ ) {
				buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "FooterIconsSettings", names[ i ], onButtonTriggered ) );
			}

			setCenterButtons( buttonGroupDefinition );
		}

		public function getSubTextureForId( id:String ):BitmapData {

			var frame:Rectangle = _atlas.getRegion( id );
//			trace( this, "getSubTextureForId: " + id + ", frame: " + frame );

			var bmd:BitmapData = new BitmapData( frame.width, frame.height, false, 0 );

			var mat:Matrix = new Matrix();
			mat.translate( -frame.x, -frame.y );

			bmd.draw( _bmd, mat );

			return bmd;
		}

		override protected function onDisabled():void {
			super.onDisabled();
			if( _atlas ) {
				_atlas.dispose();
				_atlas = null;
			}
		}
	}
}
