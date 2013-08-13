package net.psykosoft.psykopaint2.base.utils.misc
{
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	public class TrackedByteArray extends ByteArray
	{
		public function TrackedByteArray()
		{
			super();

			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().add(this);
		}

		public function dispose():void
		{
			super.clear();

			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().remove(this);
		}
	}
}