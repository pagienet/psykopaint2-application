package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.TextureBase;

	public class CopyColorTransferTexture extends FullTextureFilter
	{
		protected var _fragmentShaderData : Vector.<Number>;

		public function CopyColorTransferTexture()
		{
			_fragmentShaderData = new Vector.<Number>(40);
			_fragmentShaderData[12] = 0;
			_fragmentShaderData[13] = 0;
			_fragmentShaderData[14] = 0;
			_fragmentShaderData[15] = 1;
			_fragmentShaderData[28] = 0;
			_fragmentShaderData[29] = 0;
			_fragmentShaderData[30] = 0;
			_fragmentShaderData[31] = 1;
			_fragmentShaderData[36] = .299;
			_fragmentShaderData[37] = .587;
			_fragmentShaderData[38] = .114;
		}

		override protected function getFragmentCode() : String
		{
			// source image is always in fs0
			return 	"tex ft0, v0, fs0 <2d, nearest, mipnone>\n" +
					"m44 ft1, ft0, fc0\n" +
					"m44 ft2, ft0, fc4\n" +
					"dp3 ft3.x, ft0.xyz, fc9\n" +
					"sub ft3.x, ft3.x, fc8.x\n" +
					"mul ft3.x, ft3.x, fc8.y\n" +
					"sat ft3.x, ft3.x\n" +
					"sub ft2, ft2, ft1\n" +
					"mul ft2, ft2, ft3.x\n" +
					"add ft1, ft1, ft2\n" +
					"sub ft1, ft1, ft0\n" +
					"mul ft1, ft1, fc8.z\n" +
					"add oc, ft0, ft1";
		}

		// same stuff as passed to PyramidMapIntrinsicsStrategy
		public function setColorMatrix( matrix:Vector.<Number>, blendFactor:Number ):void
		{
			var i : int;
			for (i = 0; i < 12; ++i)
				_fragmentShaderData[i] = matrix[i];

			for (i = 0; i < 12; ++i)
				_fragmentShaderData[16+i] = matrix[12+i];

			_fragmentShaderData[32] = matrix[24];
			_fragmentShaderData[33] = matrix[25];
			_fragmentShaderData[34] = blendFactor;
		}

		override public function draw(source : TextureBase, context3D : Context3D, width : Number, height : Number) : void
		{
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentShaderData, 10);
			super.draw(source, context3D, width, height);
		}
	}
}
