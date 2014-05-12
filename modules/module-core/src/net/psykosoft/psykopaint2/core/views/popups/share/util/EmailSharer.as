package net.psykosoft.psykopaint2.core.views.popups.share.util
{

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;

public class EmailSharer extends SharerBase
{
	public function EmailSharer(manager:SocialSharingManager) {
		super(manager);
	}

	override public function share(content:Array):void {
		super.share( content );

		trace("EmailSharer - share()");
		completedSignal.dispatch();
	}
}
}
