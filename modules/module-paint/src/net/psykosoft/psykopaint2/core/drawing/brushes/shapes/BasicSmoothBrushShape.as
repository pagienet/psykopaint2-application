package net.psykosoft.psykopaint2.core.drawing.brushes.shapes
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;

	public class BasicSmoothBrushShape extends AbstractBrushShape
	{
	//	private var _blurAmount : Number = .05;
		public static const NAME:String = "basic smooth";


		public function BasicSmoothBrushShape(context3D : Context3D)
		{
			super(context3D, NAME, 128);
		}

		override protected function uploadBrushTexture(texture : Texture) : void
		{
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, false, 0);
			shp.graphics.beginFill(0xffffff);
		//	var absBlur : Number = size * _blurAmount * .5;
			shp.graphics.drawCircle(size *.5, size *.5, size * 0.5 - 10);
			shp.graphics.endFill();
			bitmapData.drawWithQuality(shp,null,null,"normal",null,true,StageQuality.BEST);
		//	bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), new BlurFilter(absBlur, absBlur, 3));
			uploadMips(_textureSize, bitmapData, texture);
			bitmapData.dispose();
		}
		
		override protected function uploadNormalSpecularMap(texture : Texture) : void
		{
			var size : Number = _textureSize;
			var shp : Shape = new Shape();
			var bitmapData : BitmapData = new TrackedBitmapData(size, size, false, 0);
			shp.graphics.beginFill(0x10cccc);
			//var absBlur : Number = size * _blurAmount * .5;
			shp.graphics.drawCircle(size *.5, size *.5, size * 0.5 - 8);
			shp.graphics.endFill();
			bitmapData.drawWithQuality(shp,null,null,"normal",null,true,StageQuality.HIGH);
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), new BlurFilter(32, 4, 3));
			uploadMips(_textureSize, bitmapData, texture);
			bitmapData.dispose();
		}
	}
}
