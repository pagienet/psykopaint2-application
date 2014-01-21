package net.psykosoft.psykopaint2.base.utils.misc
{
	// to do the most dirty hackish frame waits
	public function executeNextFrame(callback : Function, ... args) : void
	{
		new SingleFrameDelay(callback, args);
	}
}

import flash.display.Sprite;
import flash.events.Event;

class SingleFrameDelay
{
	private var _monitor:Sprite;
	private var _args:Array;
	private var _callback:Function;

	public function SingleFrameDelay(callback : Function, args : Array)
	{
		_callback = callback;
		_args = args;
		_monitor = new Sprite();
		_monitor.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	private function onEnterFrame(event:Event):void
	{
		_monitor.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		_monitor = null;
		_callback.apply(null, _args);
	}
}