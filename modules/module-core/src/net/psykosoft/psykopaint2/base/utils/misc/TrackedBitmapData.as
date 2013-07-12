package net.psykosoft.psykopaint2.base.utils.misc
{
	import flash.display.BitmapData;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	public class TrackedBitmapData extends BitmapData
	{
		public function TrackedBitmapData(width:int, height:int, transparent:Boolean=true, fillColor:uint=4.294967295E9)
		{
			super(width, height, transparent, fillColor);

			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().add(this);
		}
		
		override public function dispose():void
		{
//			trace("disposed");
			super.dispose();

			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().remove(this);
		}

		override public function clone() : BitmapData
		{
			var clone : TrackedBitmapData = new TrackedBitmapData(width, height, transparent, 0);
			clone.copyPixels(this, rect, new Point());
			return clone;
		}
	}
}