package net.psykosoft.psykopaint2.app.view.settings
{

	import net.psykosoft.psykopaint2.app.view.navigation.SubNavigationViewBase;

	public class SelectWallpaperSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK:String = "Back";

		public function SelectWallpaperSubNavigationView() {
			super( "Pick a Wallpaper" );
		}

		override protected function onEnabled():void {
			super.onEnabled();
			setLeftButton( BUTTON_LABEL_BACK );
		}

		/*public function setImages( images:Vector.<PackagedImageVO> ):void {

			var buttonGroupDefinition:ButtonGroupDefinitionVO = new ButtonGroupDefinitionVO();
			for( var i:uint; i < images.length; i++ ) {
				buttonGroupDefinition.addButtonDefinition( new ButtonDefinitionVO( images[ i ].name, onButtonTriggered ) );
			}
			setCenterButtons( buttonGroupDefinition );

			onLayout();

		}*/
	}
}
