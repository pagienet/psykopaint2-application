package net.psykosoft.psykopaint2.base.utils.events
{
	import flash.events.Event;
	
	public class DataSendEvent extends Event
	{

		public var data:*;
		
		public function DataSendEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,data:* = null)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}