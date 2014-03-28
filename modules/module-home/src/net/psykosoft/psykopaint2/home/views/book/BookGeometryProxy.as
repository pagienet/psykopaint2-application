package net.psykosoft.psykopaint2.home.views.book
{
	import away3d.core.base.Geometry;
	import away3d.primitives.PlaneGeometry;

	public class BookGeometryProxy
	{
		public static const CARD_GEOMETRY : uint = 0;

		private static var _geometries : Array;

		public function BookGeometryProxy()
		{
		}

		public static function launch() : void
		{
			_geometries = [];
			_geometries[CARD_GEOMETRY] = new PlaneGeometry(1, 1, 1, 1, true, true);
		}

		public static function getGeometryById(id:uint):Geometry
		{
			return _geometries[id];
		}

		public static function dispose() : void
		{
			for each(var geometry : Geometry in _geometries) {
				geometry.dispose();
			}
			_geometries = null;
		}
	}
}
