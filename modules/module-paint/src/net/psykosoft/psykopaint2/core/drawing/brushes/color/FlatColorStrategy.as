package net.psykosoft.psykopaint2.core.drawing.brushes.color
{
	import flash.utils.ByteArray;
	
	import net.psykosoft.psykopaint2.core.drawing.paths.SamplePoint;

	// todo: allow setting colour, but for now it's just a test class
	public class FlatColorStrategy implements IColorStrategy
	{
		private var _r : Number = 1;
		private var _g : Number = 1;
		private var _b : Number = 1;
		private var _a : Number = 1;
	//	private var _colorBlendFactor : Number = 1;
	//	private var _brushAlpha : Number = 1;

		public function FlatColorStrategy()
		{
		}

		public function get r() : Number
		{
			return _r;
		}

		public function set r(value : Number) : void
		{
			_r = value;
		}

		public function get g() : Number
		{
			return _g;
		}

		public function set g(value : Number) : void
		{
			_g = value;
		}

		public function get b() : Number
		{
			return _b;
		}

		public function set b(value : Number) : void
		{
			_b = value;
		}

		public function get a() : Number
		{
			return _a;
		}

		public function set a(value : Number) : void
		{
			_a = value;
		}

		public function getColor(x : Number, y : Number, size : Number, target : Vector.<Number>, targetIndexMask:int = 15) : void
		{
			/*
			target[0] = _r;
			target[1] = _g;
			target[2] = _b;
			target[3] = _a;
			*/
			if ( (targetIndexMask & 0xf) == 0 ) return;
			var index:int = (targetIndexMask & 1) == 1 ? 0 : (targetIndexMask & 2) == 2 ? 4 : (targetIndexMask & 4) == 4 ? 8 : (targetIndexMask & 8) == 8 ? 12 : -1;
			
			var t1:Number = target[index]   = _r;// * _brushAlpha;
			var t2:Number = target[index+1] = _g;// * _brushAlpha;
			var t3:Number = target[index+2] = _b;// * _brushAlpha;
			var t4:Number = target[index+3] = _a;// * _brushAlpha;
			if ( (targetIndexMask & 2) == 2 && index != 4)
			{
				target[4] = t1;
				target[5] = t2;
				target[6] = t3;
				target[7] = t4;
				
			}
			if ( (targetIndexMask & 4) == 4 && index != 8)
			{
				target[8] = t1;
				target[9] = t2;
				target[10] = t3;
				target[11] = t4;
				
			}
			if ( (targetIndexMask & 8) == 8 && index != 12)
			{
				target[12] = t1;
				target[13] = t2;
				target[14] = t3;
				target[15] = t4;
				
			}
		}
		
		public function getColors(point:SamplePoint, radius:Number, sampleSize : Number) : void
		{
			var targets : Vector.<Number> = point.colorsRGBA;
			var j:int = 0;
			for ( var i:int = 0; i < 4; i++ )
			{
				targets[j++] = _r;// * _brushAlpha;
				targets[j++] = _g;// * _brushAlpha;
				targets[j++] = _b;// * _brushAlpha;
				targets[j++] = _a;// * _brushAlpha;
			}
		}
		
		/*
		public function setBlendFactors(colorBlendFactor : Number, alphaBlendFactor : Number) : void
		{
			if (colorBlendFactor < 0) colorBlendFactor = 0;
			else if (colorBlendFactor > 1) colorBlendFactor = 1;
			if (alphaBlendFactor < 0) alphaBlendFactor = 0;
			else if (alphaBlendFactor > 1) alphaBlendFactor = 1;
			_colorBlendFactor = colorBlendFactor;
			_brushAlpha = alphaBlendFactor;
		}
		*/
	
	}
}
