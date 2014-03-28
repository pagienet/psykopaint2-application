package away3d.hacks
{
	import flash.display.BitmapData;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.TextureBase;

	public class BitmapRectTexture extends RectTextureBase
	{
		protected var _bitmapData:BitmapData;

		public function BitmapRectTexture(bitmapData:BitmapData)
		{
			this.bitmapData = bitmapData;
		}

		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}

		public function set bitmapData(value:BitmapData):void
		{
			if (value == _bitmapData)
				return;

			invalidateContent();
			setSize(value.width, value.height);

			_bitmapData = value;
		}

		override protected function uploadContent(texture:TextureBase):void
		{
			RectangleTexture(texture).uploadFromBitmapData(_bitmapData);
		}
	}
}
