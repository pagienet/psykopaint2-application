package net.psykosoft.psykopaint2.core.managers.social.sharers
{

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;

public class TwitterSharer extends SharerBase
{
	public function TwitterSharer(manager:SocialSharingManager) {
		super(manager);
	}

	override public function share(content:Array):void {
		super.share( content );
		//TODO
		
		trace("TwitterSharer - share()");
		_sharerName = "Twitter";

//		completedSignal.dispatch();
		failedSignal.dispatch();
	}
	
	override public function dispose():void{
		super.dispose();
		//_shareMsg = null;
		//_shareBmd.dispose();
		//_shareBmd = null;
	}
}
}
