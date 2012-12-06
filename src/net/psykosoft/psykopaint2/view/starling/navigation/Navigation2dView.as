package net.psykosoft.psykopaint2.view.starling.navigation
{

	import com.junkbyte.console.Cc;

	import feathers.controls.Button;

	import net.psykosoft.psykopaint2.assets.AssetManager;
	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;

	import starling.display.Image;
	import starling.display.Sprite;

	public class Navigation2dView extends StarlingViewBase
	{
		private var _container:Sprite;
		private var _bgImage:Image;

		public function Navigation2dView() {
			super();
		}

		private var _button:Button;

		override protected function onSetup():void {

			// Init container.
			_container = new Sprite();
			addChild( _container );

			// Init bg image.
			_bgImage = new Image( AssetManager.getTextureByName( AssetManager.NavigationBackgroundImage ) );
			_container.addChild( _bgImage );

			// Test button.
			_button = new Button();
			_button.x = 25;
			_button.y = 100;
			_button.label = "Click Me!";
			_container.addChild( _button );

			super.onSetup();

		}

		override protected function onLayout():void {

			Cc.info( this, "laying out, stage size [ " + stage.stageWidth + ", " + stage.stageHeight + "], bg image size [ " + _bgImage.width + ", " + _bgImage.height + " ]" );

			// Update container.
			_container.y = stage.stageHeight - _bgImage.height;

			// Update bg image.
			_bgImage.width = stage.stageWidth;

		}
	}
}
