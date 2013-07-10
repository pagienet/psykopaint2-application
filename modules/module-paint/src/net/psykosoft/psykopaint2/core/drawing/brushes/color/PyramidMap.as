package net.psykosoft.psykopaint2.core.drawing.brushes.color
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public class PyramidMap
	{
		private var _source:BitmapData;
		private var _scaled:BitmapData;
		private var _offsets:Vector.<Matrix>;
		
		public function PyramidMap( sourceMap:BitmapData )
		{
			setSource( sourceMap );
		}

		public function dispose() : void
		{
			_scaled.dispose();
			_scaled = null;
		}
		
		public function setSource( map:BitmapData ):void
		{
			this._source = map;

			if (_scaled) _scaled.dispose();
			_scaled = new BitmapData( Math.ceil(map.width * 0.75), Math.ceil(map.height * 0.5), true, 0 );
			var m:Matrix = new Matrix(0.5,0,0,0.5);
			_scaled.draw( map, m, null, "normal",null,true);
			m.tx += map.width * 0.5;
			_scaled.draw( _scaled, m, null, "normal",null,true);
			m.ty += map.height * 0.25;
			m.a = m.d *= 0.5;
			_scaled.draw( _scaled, m, null, "normal",null,true);
			m.a = m.d *= 0.25;
			m.tx += map.width * 0.125;
			m.ty += map.height * 0.0625;
			_scaled.draw( _scaled, m, null, "normal",null,true);
			
			var f:Number = 1;
			m = new Matrix(0.5,0,0,0.5);
			_offsets = new Vector.<Matrix>();
			_offsets.push(m.clone());
			
			for ( var i:int = 0; i < 15; i++ )
			{
				m.a = m.d *= 0.5;
				m.tx += map.width * (f *= 0.5);
				_offsets.push(m.clone());
				m.a = m.d *= 0.5;
				m.ty += map.height * (f *= 0.5);
				_offsets.push(m.clone());
			}
		}
		
		
		
		public function getPixel32( x:Number, y:Number, radius:Number ):uint
		{
			if ( radius <= 1 ) return _source.getPixel32(x,y);
			
			var index:int = Math.log(radius)/Math.log(2);
			
			
			var rad1:Number = Math.pow(2,index);
			var rad2:Number = Math.pow(2,index + 1);
			
			index-=1;
			if ( index >= 0 )
			{
				var p:Point = _offsets[index].transformPoint( new Point(x,y));
				var v1:uint = _scaled.getPixel32(p.x,p.y);
				
			} else {
				v1 = _source.getPixel32(x,y);
			}
			p = _offsets[index+1].transformPoint( new Point(x,y));
			var v2:uint = _scaled.getPixel32(p.x,p.y);
			var fi:uint = (Math.pow(2, (radius - rad1) / ( rad2 - rad1 ) ) - 1) * 65535;
			var f:uint = 65535 - fi;
			
			var a1:uint = (v1 >>> 24) & 0xff;
			var r1:uint = (v1 >>> 16) & 0xff;
			var g1:uint = (v1 >>> 8) & 0xff;
			var b1:uint = v1 & 0xff;
			
			var a2:uint = (v2 >>> 24) & 0xff;
			var r2:uint = (v2 >>> 16) & 0xff;
			var g2:uint = (v2 >>> 8) & 0xff;
			var b2:uint = v2 & 0xff;
			
			a1 = 0.5 + (( a1 * f + a2 * fi ) >>> 16);
			r1 = 0.5 +(( r1 * f + r2 * fi ) >>> 16);
			g1 = 0.5 +(( g1 * f + g2 * fi ) >>> 16);
			b1 = 0.5 +(( b1 * f + b2 * fi ) >>> 16);
			
			return (a1 << 24) | (r1 << 16) | (g1 << 8) | b1;
			
		}
	}
}