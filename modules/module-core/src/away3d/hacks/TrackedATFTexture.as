package away3d.hacks
{

	import away3d.textures.ATFTexture;

	import flash.utils.ByteArray;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	public class TrackedATFTexture extends ATFTexture
	{
		public function TrackedATFTexture(byteArray:ByteArray)
		{
			super(byteArray);

		//	trace("TrackedATFTexture::create"+this);

			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().add(this);
		}

		override public function dispose():void
		{
			super.dispose();
		//	trace("TrackedATFTexture::dispose"+this);

			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().remove(this);
		}
	}
}
