package net.psykosoft.psykopaint2.base.utils.misc
{
	import flash.display.BitmapData;
	
	public class DebugBitmapData extends BitmapData
	{
		public function DebugBitmapData(width:int, height:int, transparent:Boolean=true, fillColor:uint=4.294967295E9)
		{
			super(width, height, transparent, fillColor);
		}
		
		override public function dispose():void
		{
			trace("disposed");
			super.dispose();
		}
	}
}