package net.psykosoft.psykopaint2.home.views.book
{
	import away3d.core.base.Geometry;
	import away3d.primitives.PlaneGeometry;

	public class HomeGeometryCache
	{
		public static const CARD_GEOMETRY : uint = 0;
		public static const FRAME_GEOMETRY : uint = 1;

		private static var _geometries : Array;

		public function HomeGeometryCache()
		{
		}

		public static function launch() : void
		{
			_geometries = [];
			_geometries[CARD_GEOMETRY] = new PlaneGeometry(1, 1, 1, 1, true, true);
			_geometries[FRAME_GEOMETRY] = new PlaneGeometry(1, 1, 1, 1, false);
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
