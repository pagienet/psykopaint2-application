package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class SquareBrushShape extends AbstractBrushShape
	{
		public function SquareBrushShape(context3D : Context3D)
		{
			super(context3D, "square", 1);
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, true, 0);
			shp.graphics.beginFill(0xffffff);
			shp.graphics.drawRect(0, 0, size, size);
			shp.graphics.endFill();
			bitmapData.draw(shp);
			texture.uploadFromBitmapData(bitmapData);
			bitmapData.dispose();
		}
	}
}
