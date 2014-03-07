package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.TextureBase;

	public class CopyTextureWithAlpha extends FullTextureFilter
	{
		private var copyAlpha:Number;
		private static var _instance : CopyTextureWithAlpha;

		public function CopyTextureWithAlpha()
		{
		}

		// use a static method because this is so universally used. (still bleh, tho)
		public static function copy(source : TextureBase, context3D : Context3D, width : Number = 1, height : Number = 1, alpha:Number = 1) : void
		{
			if (!_instance)
				throw new Error("CopyTextureWithAlpha::init must be called first!");
			_instance.copyAlpha = alpha;
			_instance.draw(source, context3D, width, height);
		}
		
		public static function init(context3D : Context3D) : void
		{
			_instance ||= new CopyTextureWithAlpha();
			_instance.init(context3D);
		}
		
		public static function dispose() : void
		{
			if (_instance) _instance.dispose();
		}
		
		override protected function getFragmentCode() : String
		{
			// source image is always in fs0
			return "tex ft0, v0, fs0 <2d, nearest, mipnone>\n"+
				   "mul oc, ft0, fc0\n";
			
		}
		
		override public function draw(source : TextureBase, context3D : Context3D, width : Number, height : Number) : void
		{
			init(context3D);
			
			_vertexShaderData[4] = width*2;
			_vertexShaderData[5] = height*2;
			_vertexShaderData[8] = width;
			_vertexShaderData[9] = height;
			
			_context3D.setProgram(_program);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexShaderData, 4);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([copyAlpha,copyAlpha,copyAlpha,copyAlpha]), 1);
			setRenderState(source);
			_context3D.drawTriangles(_quadIndices,0,2);
			clearRenderState();
		}
	}
}
