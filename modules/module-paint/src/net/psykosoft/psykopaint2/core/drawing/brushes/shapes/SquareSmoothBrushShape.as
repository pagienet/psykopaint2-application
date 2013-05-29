package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.filters.BlurFilter;
	import flash.geom.Point;

	public class SquareSmoothBrushShape extends AbstractBrushShape
	{
		private var _blurAmount : Number = .25;

		public function SquareSmoothBrushShape(context3D : Context3D)
		{
			super(context3D, "square smooth", 1);
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new BitmapData(size, size, true, 0);
			var absBlur : Number = size * _blurAmount * .5;
			shp.graphics.beginFill(0xffffff);
			shp.graphics.drawRect(absBlur, absBlur, size - 2*absBlur, size - 2*absBlur);
			shp.graphics.endFill();
			bitmapData.draw(shp);
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), new BlurFilter(absBlur, absBlur, 3));
			texture.uploadFromBitmapData(bitmapData);
			bitmapData.dispose();
		}
	}
}
