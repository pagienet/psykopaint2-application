package net.psykosoft.psykopaint2.core.data
{
	import flash.utils.ByteArray;
	
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedByteArray;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	public class PaintingDataVO
	{
		public var colorData:ByteArray;
		public var normalSpecularData:ByteArray;
		public var sourceImageData:ByteArray;
		public var normalSpecularOriginal:ByteArray;
		public var colorBackgroundOriginal:ByteArray;
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
			colorData.clear();
			if (normalSpecularData) normalSpecularData.clear();
			if (sourceImageData) sourceImageData.clear();
			if (normalSpecularOriginal) normalSpecularOriginal.clear();
			if (colorBackgroundOriginal) colorBackgroundOriginal.clear();
			colorData = null;
			normalSpecularData = null;
			sourceImageData = null;
			normalSpecularOriginal = null;
			colorBackgroundOriginal = null;
		}
	}
}
