package net.psykosoft.psykopaint2.core.drawing.shaders.water
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.drawing.shaders.SimStepRenderer;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class TransferPigment extends SimStepRenderer
	{
		private var _canvas : CanvasModel;
		private var _props : Vector.<Number>;

		[Embed(source="/../shaders/agal/TransferPigment.agal", mimeType="application/octet-stream")]
		private var Shader : Class;

		public function TransferPigment(context : Context3D, canvas : CanvasModel)
		{
			super(context);
			_canvas = canvas;
			_props = Vector.<Number>([	0, 0, 0, 0,	// granulation
				0, 0, 0, 0,	// density
				0, 0, 0, 0,	// rcpStaining
				1, -1, 0, 0,	// general constants
				0, 0, 0, 0 		// cmp-related
			]);
		}

		override protected function getFragmentProgram() : String
		{
			return EmbedUtils.StringFromEmbed(Shader);
		}

		public function execute(stroke : SimulationMesh, pigment : Texture, pigmentGranulation : Number, pigmentDensity : Number, pigmentStaining : Number) : void
		{
			_context.setRenderToTexture(_canvas.halfSizeBackBuffer, true);
			_context.setTextureAt(0, pigment);
			_context.setTextureAt(1, _canvas.normalSpecularMap);
			_context.clear();
			_props[0] = pigmentGranulation;
			_props[4] = pigmentDensity;
			_props[8] = pigmentDensity/pigmentStaining;
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _props, 5);
			render(stroke);
			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
		}
	}
}