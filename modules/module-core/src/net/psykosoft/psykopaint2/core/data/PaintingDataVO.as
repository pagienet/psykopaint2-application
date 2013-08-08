package net.psykosoft.psykopaint2.core.data
{

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	public class PaintingDataVO
	{
		public var colorData:ByteArray;
		public var normalSpecularData:ByteArray;
		public var sourceBitmapData:ByteArray;
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
			normalSpecularData.clear();
			sourceBitmapData.clear();
			colorData = null;
			normalSpecularData = null;
			sourceBitmapData = null;
		}
	}
}
