////Generated by Prefab3D 2.147, Tue Oct 29 11:37:37 GMT+0100 2013. www.closier.nl/prefab
package net.psykosoft.psykopaint2.home.views.home.atelier.data
{

	import away3d.core.base.Geometry;

	public class DomeData
	{

		[Embed(source="/../assets/embedded/away3d/atelier/asd/DomeData.asd", mimeType="application/octet-stream")]
		private var DomeDataASD : Class;

		public function get geometryData() : Geometry
		{
			return ASDReader.decodeGeometry(new DomeDataASD());
		}

	}
}