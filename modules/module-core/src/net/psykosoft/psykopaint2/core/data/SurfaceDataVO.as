package net.psykosoft.psykopaint2.core.data
{
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedByteArray;

	public class SurfaceDataVO
	{
		public var normalSpecular : RefCountedByteArray;
		public var color : RefCountedByteArray;

		public function dispose() : void
		{
			normalSpecular.dispose();
			if (color) color.dispose();
			color = null;
			normalSpecular = null;
		}
	}
}
