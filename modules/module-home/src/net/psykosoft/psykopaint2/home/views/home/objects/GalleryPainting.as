package net.psykosoft.psykopaint2.home.views.home.objects
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;

	public class GalleryPainting extends ObjectContainer3D
	{
		public function get width() : Number
		{
			return 1500;
		}

		public function get painting() : Mesh
		{
			return null;
		}
	}
}
