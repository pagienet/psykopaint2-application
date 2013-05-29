package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	public class SoftShadowModel extends BDRFModel
	{
		private var _vertexShaderData : Vector.<Number>;
		private var _fragmentShaderData : Vector.<Number>;

		private var range : Number = 5	/ 2048;


		public function SoftShadowModel()
		{
			super();
			_vertexShaderData = new <Number>[range, range, range, 0];
			// blue-ish shadow color:
			_fragmentShaderData = new <Number>[15, 0, 0, 0];
		}

		override public function getVertexCode() : String
		{
			return 	"mul vt6, vt4, vc10\n" +
					"add v6, vt0, vt6\n";
		}

		override public function getFragmentCode() : String
		{
			return 	"tex ft5, v6, fs2 <2d, clamp, linear, mipnone>\n" +
					"sub ft4.x, ft5.x, ft7.x\n" +
					"mul ft4.x, ft4.x, fc20.x\n" +
					"sat ft4.x, ft4.x\n" +
					"sub ft7.w, fc0.z, ft4.x\n";
		}

		override public function updateLightingModel(lightingModel : LightingModel) : void
		{
		}

		override public function setRenderState(context : Context3D) : void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 10, _vertexShaderData, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 20, _fragmentShaderData, 1);
		}
	}
}
