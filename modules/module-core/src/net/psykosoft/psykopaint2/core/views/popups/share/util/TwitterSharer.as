package net.psykosoft.psykopaint2.core.views.popups.share.util
{

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;

public class TwitterSharer extends SharerBase
{
	public function TwitterSharer(manager:SocialSharingManager) {
		super(manager);
	}

	override public function share(content:Array):void {
		super.share( content );

		trace("TwitterSharer - share()");
		completedSignal.dispatch();
	}
}
}
