package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.drawing.shaders.SimStepRenderer;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class UpdateVelocities extends SimStepRenderer
	{
		private var _canvas : CanvasModel;
		private var _vertexProps : Vector.<Number>;
		private var _fragmentProps : Vector.<Number>;

		[Embed(source="/../shaders/agal/UpdateVelocities.agal", mimeType="application/octet-stream")]
		private var Shader : Class;

		public function UpdateVelocities(canvas : CanvasModel)
		{
			_canvas = canvas;

			_vertexProps = Vector.<Number>([
				4/canvas.textureWidth, 4/canvas.textureHeight, 0, 0,	// texelSize
				2/canvas.textureWidth, -1/canvas.textureHeight, 0, 0,
				-4/canvas.textureWidth, 4/canvas.textureHeight, 0, 0
			]);

			_fragmentProps = Vector.<Number>([
				0, 0, 0, 0,	// viscosity
				0, 0, 0, 0,	//  drag
				0, 0, 0, 0,	// dt
				-0.5, 2, 8, 0.5 	// defined constants
			]);
		}

		override protected function getVertexProgram() : String
		{
			var code : String =
					"mov v0, va1\n" +

					"add v1, va1, vc0.xzzz\n" +	// + texelSize.xz
					"sub v2, va1, vc0.xzzz\n" +	// - texelSize.xz
					"sub v3, va1, vc0.zyzz\n" +	// - texelSize.zy
					"add v4, va1, vc0.zyzz\n" +	// + texelSize.zy
					"add v5, va1, vc1.xyzz\n" +	// 	+ halfTexelSize.xy + halfTexelSize.zy =(.5, -1.0)
					"add v6, va1, vc2.xyzz\n" +	//  - halfTexelSize.xy - halfTexelSize.xz = (-1, .5)

					"mov op, va0\n";
			return code;
		}

		override protected function getFragmentProgram() : String
		{
			return EmbedUtils.StringFromEmbed(Shader);
		}

		public function execute(context : Context3D, stroke : SimulationMesh, velocityDensity : Texture, target : Texture, dt : Number = 1, waterViscosity : Number = .1, waterDrag : Number = .01) : void
		{
			context.setRenderToTexture(target, true);
			context.setTextureAt(0, velocityDensity);
			context.clear(.5, .5, 0, 1);
			_fragmentProps[0] = waterViscosity;
			_fragmentProps[4] = waterDrag;
			_fragmentProps[8] = dt;
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vertexProps, 3);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentProps, 4);
			render(context, stroke);
		}
	}
}