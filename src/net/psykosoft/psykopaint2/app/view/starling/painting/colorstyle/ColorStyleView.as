package net.psykosoft.psykopaint2.app.view.starling.painting.colorstyle
{

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.app.view.starling.base.StarlingViewBase;

	import starling.display.Image;
	import starling.textures.Texture;

	public class ColorStyleView extends StarlingViewBase
	{
		private var _previewImage:Image;
		private var _texture:Texture;
		private var _resultMap:BitmapData;
		private var _sourceMap:BitmapData;

		public function ColorStyleView() {
			super();
		}

		protected function centerCanvas():void
		{
			if ( _previewImage )
			{
				_previewImage.x = 0.5 * ( stage.stageWidth - _previewImage.width );
				_previewImage.y = 0.5 * ( stage.stageHeight - _previewImage.height);
			}
		}

		public function updatePreview():void
		{
			if ( _texture ) _texture.dispose();
			_texture = Texture.fromBitmapData( _resultMap );

			if (!_previewImage ){
				_previewImage = new Image( _texture );
				addChild( _previewImage );
			} else {
				_previewImage.texture = _texture;
			}
			centerCanvas();
		}

		public function set resultMap( map:BitmapData ):void
		{
			_resultMap = map;
			updatePreview();
		}
	}
}
