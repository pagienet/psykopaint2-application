package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.drawing.shaders.SimStepRenderer;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class PreviewPigmentRGB extends SimStepRenderer
	{
		private var _canvas : CanvasModel;
		private var _props : Vector.<Number>;

		public function PreviewPigmentRGB(context : Context3D, canvas : CanvasModel)
		{
			super(context, false);
			_canvas = canvas;
			_props = Vector.<Number>([0, 0, 0, 1]);
		}


		override protected function getVertexProgram() : String
		{
			var code : String =
					"mov v0, va1\n" +
					"mul op, va0, vc0\n";
			return code;
		}

		override protected function getFragmentProgram() : String
		{
			return 	"tex ft0, v0, fs0 <2d,linear,clamp>	\n" +
					"mul ft0.xyz, ft0.xyz, ft0.w\n" +
					"mov oc, ft0";
		}

		public function execute(stroke : SimulationMesh, pigment : Texture, scaleX : Number = 1, scaleY : Number = 1) : void
		{
			_context.setTextureAt(0, pigment);
			_props[0] = scaleX;
			_props[1] = scaleY;
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _props, 1);
			render(stroke);
			_context.setTextureAt(0, null);
		}
	}
}