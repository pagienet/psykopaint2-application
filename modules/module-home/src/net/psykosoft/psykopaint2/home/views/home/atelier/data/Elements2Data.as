////Generated by Prefab3D 2.147, Tue Oct 29 11:37:37 GMT+0100 2013. www.closier.nl/prefab
package net.psykosoft.psykopaint2.home.views.home.atelier.data
{

	import away3d.core.base.Geometry;

	public class Elements2Data
	{

		[Embed(source="/../assets/embedded/away3d/atelier/asd/Elements2Data.asd", mimeType="application/octet-stream")]
		private var Elements2DataASD : Class;

		public function get geometryData() : Geometry
		{
			return ASDReader.decodeGeometry(new Elements2DataASD());
		}

	}
}