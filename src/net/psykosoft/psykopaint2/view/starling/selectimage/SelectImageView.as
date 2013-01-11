package net.psykosoft.psykopaint2.view.starling.selectimage
{

	import feathers.controls.Label;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;

	import starling.core.Starling;

	import starling.display.Image;
	import starling.textures.Texture;

	public class SelectImageView extends StarlingViewBase
	{
		private var _thumbImages:Vector.<Image>;

		public function SelectImageView() {
			super();
		}

		override protected function onStageAvailable():void {

			var label:Label = new Label();
			label.text = "Displays images the user can load to start painting on.\nPlease select an image bank source.";
			addChild( label );
			label.validate();
			label.x = stage.stageWidth / 2 - label.width / 2;
			label.y = stage.stageHeight / 2 - label.height / 2;

			super.onStageAvailable();
		}

		public function displayThumbs( bitmapDatas:Vector.<BitmapData> ):void {
			for( var i:uint; i < bitmapDatas.length; i++ ) {
				var bmd:BitmapData = bitmapDatas[ i ];
				var texture:Texture = Texture.fromBitmapData( bmd, false, false, Starling.contentScaleFactor );
				var image:Image = new Image( texture );
				_thumbImages.push( image );
			}
			// TODO: view feathers tile list example to display the images
		}

		private function disposeImages():void {
			//TODO
			_thumbImages = new Vector.<Image>();
		}
	}
}
