package net.psykosoft.psykopaint2.core.data
{
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedByteArray;

	public class PaintingDataVO
	{
		public var colorData:RefCountedByteArray;
		public var normalSpecularData:RefCountedByteArray;
		public var sourceBitmapData:RefCountedByteArray;
		public var normalSpecularOriginal:RefCountedByteArray;
		public var colorBackgroundOriginal : RefCountedByteArray;
		public var width:uint;
		public var height:uint;

		public function PaintingDataVO()
		{
			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().add(this);
			super();
		}

		public function dispose() : void
		{
			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().remove(this);
			colorData.dispose();
			normalSpecularData.dispose();
			sourceBitmapData.dispose();
			if (normalSpecularOriginal) normalSpecularOriginal.dispose();
			if (colorBackgroundOriginal) colorBackgroundOriginal.dispose();
			colorData = null;
			normalSpecularData = null;
			sourceBitmapData = null;
			normalSpecularOriginal = null;
			colorBackgroundOriginal = null;
		}
	}
}
