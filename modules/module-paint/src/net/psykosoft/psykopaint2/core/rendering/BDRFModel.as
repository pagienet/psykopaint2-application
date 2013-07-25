package net.psykosoft.psykopaint2.core.rendering
{
	import flash.display3D.Context3D;

	import net.psykosoft.psykopaint2.base.errors.AbstractMethodError;

	import net.psykosoft.psykopaint2.core.model.LightingModel;

	public class BDRFModel
	{
		public function updateLightingModel(lightingModel : LightingModel) : void
		{

		}

		public function setRenderState(context : Context3D) : void
		{

		}

		public function getVertexCode() : String
		{
			return "";
		}

		// only for stuff like ambient
		public function get outputRegister() : String
		{
			return "ft4";
		}

		public function clearRenderState(context : Context3D) : void
		{

		}

		public function getFragmentCode() : String
		{
			throw new AbstractMethodError();
		}
	}
}
