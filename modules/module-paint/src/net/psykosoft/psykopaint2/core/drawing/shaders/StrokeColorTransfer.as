package net.psykosoft.psykopaint2.core.drawing.shaders
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;

	import net.psykosoft.psykopaint2.core.drawing.brushes.strokes.SimulationMesh;

	import net.psykosoft.psykopaint2.core.rendering.CopyTexture;
	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class StrokeColorTransfer
	{
		private var _program : Program3D;
		private var _context : Context3D;
		private var _triOffset : int;

		[Embed(source="/../shaders/agal/AddCMYKPigment.agal", mimeType="application/octet-stream")]
		private var Shader : Class;

		private var _props : Vector.<Number>;
		private var _subtractive : Boolean;

		public function StrokeColorTransfer(context3d : Context3D)
		{
			_context = context3d;
			_props = Vector.<Number>([1, 0, 0, 0]);
			init();
		}

		public function dispose() : void
		{
			_program.dispose();
			_program = null;
		}

		private function init() : void
		{
			initProgram();
		}

		public function reset() : void
		{
			_triOffset = 0;
		}

		private function initProgram() : void
		{
			_program = _context.createProgram();

			var fragmentCode : String;
			var vertexCode : String;


			if (_subtractive) {
				vertexCode = "mov op, va0\n" +
							"mov v0, va1\n" +
							"mov v1, va2\n" +
							"mov v2, va3\n";
				fragmentCode = EmbedUtils.StringFromEmbed(Shader);
			}
			else {
				vertexCode = "mov op, va0\n" +
							"mov v1, va1\n" +
							"mov v0, va2\n";
				fragmentCode = "tex ft0, v1, fs0 <2d,linear,clamp>	\n" +
								"mul oc, v0, ft0.w\n";
			}

			_program.upload(	new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, vertexCode),
								new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, fragmentCode)
			);
		}

		public function execute(stroke : SimulationMesh, source : TextureBase, target : TextureBase, brushTexture : TextureBase, textureRatioX : Number, textureRatioY : Number) : void
		{
			const overlapPreventionTris : int = 4;
			var triOffset : int = _triOffset <= overlapPreventionTris? 0 : _triOffset-overlapPreventionTris;
			var stationaryEnd : int = stroke.numTriangles - stroke.stationaryTriangleCount;
			if (triOffset > stationaryEnd) triOffset = stationaryEnd;
			// nothing new
			if (triOffset == stroke.numTriangles) return;

			_context.setRenderToTexture(target, true);
			_context.clear(1, 1, 1, 1);

			CopyTexture.copy(source, _context, textureRatioX, textureRatioY);

			_context.setProgram(_program);
			_context.setTextureAt(0, brushTexture);

			_context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.EQUAL, Context3DStencilAction.INCREMENT_SATURATE, Context3DStencilAction.INCREMENT_SATURATE, Context3DStencilAction.INCREMENT_SATURATE);
			_context.setStencilReferenceValue(0);
			_context.setColorMask(false, false, false, false);

			if (_subtractive) {
				_context.setTextureAt(1, source);
				_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
				_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _props, 1);

				drawWithoutOverlap(stroke, SimulationMesh.BRUSH_TEXTURE_UVS | SimulationMesh.CANVAS_TEXTURE_UVS, triOffset, overlapPreventionTris);
			}
			else {
				drawWithoutOverlap(stroke, SimulationMesh.BRUSH_TEXTURE_UVS, triOffset, overlapPreventionTris);
			}

			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			_context.setStencilActions();
			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
			_triOffset = stroke.numTriangles;
		}

		private function drawWithoutOverlap(stroke : SimulationMesh, uvMode : int, offset : int, overlapCount : int) : void
		{
			if (offset > 0) {
				_context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.EQUAL, Context3DStencilAction.INCREMENT_SATURATE, Context3DStencilAction.INCREMENT_SATURATE, Context3DStencilAction.INCREMENT_SATURATE);
				_context.setStencilReferenceValue(0);
				_context.setColorMask(false, false, false, false);
				stroke.drawMesh(_context, uvMode, overlapCount, false, offset);
				_context.setColorMask(true, true, true, true);
			}
			stroke.drawMesh(_context, uvMode, -1, true, offset);
		}
	}
}
