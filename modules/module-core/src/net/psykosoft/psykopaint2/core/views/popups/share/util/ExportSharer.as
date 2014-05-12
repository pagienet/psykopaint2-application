package net.psykosoft.psykopaint2.core.views.popups.share.util
{

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;

public class ExportSharer extends SharerBase
{
	public function ExportSharer(manager:SocialSharingManager) {
		super(manager);
	}

	override public function share(content:Array):void {
		super.share( content );

		trace("ExportSharer - share()");
		completedSignal.dispatch();
	}
}
}
