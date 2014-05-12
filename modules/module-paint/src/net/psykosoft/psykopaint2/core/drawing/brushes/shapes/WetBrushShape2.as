package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class WetBrushShape2 extends AbstractBrushShape
	{
		public static const NAME:String="wet2";
		
		public function WetBrushShape2(context3D : Context3D)
		{
			super(context3D, "wet2", 3.0);
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, true, 0);
			shp.graphics.beginFill(0xffffff);
			shp.graphics.drawCircle(size * .5, size * .5, size * .5 / _scaleFactor);
			shp.graphics.endFill();
			bitmapData.draw(shp);
			var blur : BlurFilter = new BlurFilter(size * .25, size * .25, 3);
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), blur);
			texture.uploadFromBitmapData(bitmapData);
			bitmapData.dispose();
		}


		override protected function setVariationFactors(cols : int, rows : int) : void
		{
			super.setVariationFactors(cols, rows);

			// kind of nasty, but why was the meaning of scale factor changed? :s
			_scaleFactor = 3;
		}
	}
}
