package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.textures.TextureBase;
	
	public class BackbufferTextureFilter extends FullTextureFilter
	{
		public function BackbufferTextureFilter()
		{
			super();
		}
		
		override protected function initGeometry() : void
		{
			_quadVertices = _context3D.createVertexBuffer(4,4);
			_quadIndices = _context3D.createIndexBuffer(6);
			
			// is there a different way to get the scale factor that does not involve Starling?
//			var scale:Number = 1 / Starling.current.contentScaleFactor;
			var scale:Number = 1;
			// viewport size is 1024 * 748 -> ratio 0.73046875
			_quadVertices.uploadFromVector(new <Number>[	
				-1.0, -1.0, 0.0, 0.73046875 * scale,
				1.0, -1.0, 1.0* scale, 0.73046875 * scale,
				1.0, 1.0, 1.0* scale, 0.0,
				-1.0,1.0, 0.0, 0.0], 0, 4);
			_quadIndices.uploadFromVector(new <uint>[0, 1, 2, 0, 2, 3], 0, 6);
		}
		
		override public function draw(source : TextureBase, context3D : Context3D, width : Number, height : Number) : void
		{
			if (context3D != _context3D) {
				this.dispose();
				_context3D = context3D;
			}
			if (!_program) initProgram();
			if (!_quadVertices) initGeometry();

			_context3D.setProgram(_program);
			setRenderState(source);
			_context3D.drawTriangles(_quadIndices,0,2);
			clearRenderState();
		}
		
		override protected function getFragmentCode() : String
		{
			// source image is always in fs0
			return "tex oc, v0, fs0 <2d, clamp, nearest, mipnone>";
		}
		
		override protected function getVertexCode() : String
		{
			return 	"mov op, va0\n" +
				   "mov v0,  va1\n";
		}
	}
}
