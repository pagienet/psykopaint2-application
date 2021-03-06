package net.psykosoft.psykopaint2.core.managers.social.sharers
{

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;

import org.osflash.signals.Signal;

public class SharerBase
{
	protected var _manager:SocialSharingManager;
	protected var _contentToBeShared:Array;
	protected var _sharerName:String = "";

	public var completedSignal:Signal = new Signal();
	public var failedSignal:Signal = new Signal();
	public var abortedSignal:Signal = new Signal();

	public function SharerBase(manager:SocialSharingManager) {
		super();
		_manager = manager;
	}

	public function get sharerName():String {
		return _sharerName;
	}

	public function share(content:Array):void {
		_contentToBeShared = content;
	}

	public function dispose():void {
		_manager = null;
		_contentToBeShared = null;
	}
}
}
