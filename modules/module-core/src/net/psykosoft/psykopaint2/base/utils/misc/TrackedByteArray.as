package net.psykosoft.psykopaint2.base.utils.misc
{
	import flash.utils.ByteArray;
	
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	public class TrackedByteArray extends ByteArray
	{
		public function TrackedByteArray()
		{
			/*
			if ( nativeByteArray != null )
			{
				this.endian = nativeByteArray.endian;
				this.writeBytes( nativeByteArray );
				this.position = nativeByteArray.position;
			}
			*/
			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().add(this);
		}
		
		override public function clear():void
		{
//			trace("disposed");
			super.clear();
			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().remove(this);
		}
	}
}