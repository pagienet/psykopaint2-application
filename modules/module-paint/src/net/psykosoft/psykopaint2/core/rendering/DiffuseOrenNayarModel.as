package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	import net.psykosoft.psykopaint2.core.utils.EmbedUtils;

	public class DiffuseOrenNayarModel extends BDRFModel
	{
		[Embed(source="/../shaders/agal/CanvasDiffuseOrenNayar.agal", mimeType="application/octet-stream")]
		private var Shader : Class;

		protected var _fragmentShaderData : Vector.<Number>;

		private var _lookUp : Texture;
		private var _roughness : Number = .5;

		public function DiffuseOrenNayarModel()
		{
			super();
			_fragmentShaderData = new <Number>[
				0, 0, 0, 0,
				 0.5, 1, 0.5, 2.8
			];
		}

		override public function getFragmentCode() : String
		{
			return EmbedUtils.StringFromEmbed(Shader);
		}

		override public function setRenderState(context : Context3D) : void
		{
			if (!_lookUp) initLookUp(context);

			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, _fragmentShaderData, 2);
			context.setTextureAt(3, _lookUp);
		}

		override public function clearRenderState(context : Context3D) : void
		{
			context.setTextureAt(3, null);
		}

		override public function updateLightingModel(lightingModel : LightingModel) : void
		{
			var roughSqr : Number = _roughness*_roughness;

			_fragmentShaderData[0] = 1.0 - 0.5 * roughSqr / (roughSqr + 0.57);
			_fragmentShaderData[1] = 0.45 * roughSqr / (roughSqr + 0.09);
		}

		private function initLookUp(context : Context3D) : void
		{
			var lookUpSize : int = 256;
			var ba : ByteArray = new ByteArray();

			for (var y : uint = 0; y < lookUpSize; ++y) {
				for (var x : uint = 0; x < lookUpSize; ++x) {
					var VdotN : Number = x / lookUpSize * 2 - 1;
					var LdotN : Number = y / lookUpSize * 2 - 1;
					var acosVdotN : Number = Math.acos(VdotN);
					var acosLdotN : Number = Math.acos(LdotN);
					var alpha : Number = acosVdotN > acosLdotN? acosVdotN : acosLdotN;
					var beta  : Number = acosVdotN < acosLdotN? acosVdotN : acosLdotN;
					var value : Number = Math.sin(alpha) * Math.tan(beta);
					value = value / 2.8 + .5;	       	// maximum in [0, 1] =~ 1.31
					ba.writeByte(int(value * 0xff) & 0xff);
					ba.writeByte(int(value * 0xff) & 0xff);
					ba.writeByte(int(value * 0xff) & 0xff);
					ba.writeByte(int(value * 0xff) & 0xff);
				}
			}

			_lookUp = context.createTexture(lookUpSize, lookUpSize, Context3DTextureFormat.BGRA, false);
			_lookUp.uploadFromByteArray(ba, 0);
		}
	}
}
