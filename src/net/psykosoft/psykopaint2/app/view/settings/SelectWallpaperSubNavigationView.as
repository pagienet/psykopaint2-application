package net.psykosoft.psykopaint2.app.view.settings
{

	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;

	import starling.textures.Texture;

	import starling.textures.TextureAtlas;

	public class SelectWallpaperSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK:String = "Back";

		private var _atlas:TextureAtlas;

		public function SelectWallpaperSubNavigationView() {
			super( "Pick a Wallpaper" );
		}

		override protected function onEnabled():void {
			super.onEnabled();
			setLeftButton( "FooterIconsSettings",BUTTON_LABEL_BACK );
		}

		public function setImages( atlas:TextureAtlas ):void {

			_atlas = atlas;
			var names:Vector.<String> = atlas.getNames();
			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			for( var i:uint; i < names.length; i++ ) {
				buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( "FooterIconsSettings", names[ i ], onButtonTriggered ) ); // TODO: apply proper skin
			}
			setCenterButtons( buttonGroupDefinition );
		}

		public function getSubTextureForId( id:String ):Texture {
			return _atlas.getTexture( id );
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
