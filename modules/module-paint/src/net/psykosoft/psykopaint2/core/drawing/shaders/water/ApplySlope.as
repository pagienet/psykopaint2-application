package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import flash.geom.Vector3D;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;
	import net.psykosoft.psykopaint2.core.drawing.shaders.SimStepRenderer;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;

	public class ApplySlope extends SimStepRenderer
	{
		private var _canvas : CanvasModel;
		private var _fragmentProps : Vector.<Number>;
		private var _vertexProps : Vector.<Number>;
		private var _gravityStrength : Number = .1;

		public function ApplySlope(canvas : CanvasModel)
		{
			_canvas = canvas;
			_vertexProps = Vector.<Number>([1/canvas.textureWidth, 1/canvas.textureHeight, 0, 0]);
			_fragmentProps = Vector.<Number>([.5, 2, 0, 0, 0, 0, 0, 0]);
		}

		public function get surfaceRelief() : Number
		{
			return _fragmentProps[2];
		}

		public function set surfaceRelief(value : Number) : void
		{
			_fragmentProps[2] = value;
		}

		public function get gravityStrength() : Number
		{
			return _gravityStrength;
		}

		public function set gravityStrength(value : Number) : void
		{
			_gravityStrength = value;
		}

		override protected function getVertexProgram() : String
		{
			return 	"mov v0, va1\n" +
					"mov op, va0\n" +
					"add v1, va1, vc0.xzzz\n" +
					"add v2, va1, vc0.zyzz\n";
		}

		override protected function getFragmentProgram() : String
		{
			return 	"tex ft0, v0, fs0 <2d,nearest,clamp>	\n" +
					"tex ft2, v0, fs1 <2d,nearest,clamp>	\n" +
					"tex ft3, v1, fs1 <2d,nearest,clamp>	\n" +
					"tex ft4, v2, fs1 <2d,nearest,clamp>	\n" +

					"sub ft1.x, ft3.x, ft2.x\n" +
					"sub ft1.y, ft4.x, ft2.x\n" +

					"mul ft1.xy, ft1.xy, fc0.z				\n" +
					"add ft0.xy, ft0.xy, ft1.xy				\n" +
					"add ft0.xy, ft0.xy, fc1.xy				\n" +
					"mov oc, ft0";
		}

		public function execute(context : Context3D, gravity : Vector3D, stroke : SimulationMesh, velocityDensity : Texture, target : Texture) : void
		{
			context.setRenderToTexture(target, false);
			context.setTextureAt(0, velocityDensity);
			context.setTextureAt(1, _canvas.heightSpecularMap);
			_fragmentProps[4] = -gravity.x*_gravityStrength;
			_fragmentProps[5] = gravity.y*_gravityStrength;

			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexProps, 1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentProps, 2);
			context.clear(.5,.5, 0, 0);

			render(context, stroke);

			context.setTextureAt(1, null);
		}


	}
}
