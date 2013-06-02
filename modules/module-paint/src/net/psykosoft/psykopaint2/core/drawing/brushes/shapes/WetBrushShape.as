package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;

	public class WetBrushShape extends AbstractBrushShape
	{
		public function WetBrushShape(context3D : Context3D)
		{
			super(context3D, "wet", 3.0);
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new BitmapData(size, size, true, 0);
			shp.graphics.beginFill(0xffffff);
			shp.graphics.drawCircle(size * .5, size * .5, size * .5 / _scaleFactor);
			shp.graphics.endFill();
			bitmapData.draw(shp);
			texture.uploadFromBitmapData(bitmapData);
			bitmapData.dispose();
		}
	}
}