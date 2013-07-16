package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;

	public class GalleryPainting extends ObjectContainer3D
	{
		private var _width:Number = 0;

		public function get painting():Mesh {
			return null;
		}

		public function set width( value:Number ):void {
			_width = value;
		}

		public function get width():Number {
			return _width;
		}
	}
}
