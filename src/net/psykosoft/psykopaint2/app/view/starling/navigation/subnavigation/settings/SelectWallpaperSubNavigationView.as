package net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.settings
{

	import net.psykosoft.psykopaint2.app.view.starling.navigation.subnavigation.base.SubNavigationViewBase;

	public class SelectWallpaperSubNavigationView extends SubNavigationViewBase
	{
		public static const BUTTON_LABEL_BACK:String = "Back";

		public function SelectWallpaperSubNavigationView() {
			super( "Pick a Wallpaper" );
		}

		override protected function onStageAvailable():void {

			setLeftButton( BUTTON_LABEL_BACK );

			super.onStageAvailable();
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