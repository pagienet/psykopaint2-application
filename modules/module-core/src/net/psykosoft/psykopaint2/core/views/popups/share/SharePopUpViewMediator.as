package net.psykosoft.psykopaint2.core.views.popups.share
{

import flash.display.BitmapData;

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;
import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
import net.psykosoft.psykopaint2.core.views.popups.share.util.FacebookSharer;
import net.psykosoft.psykopaint2.core.views.popups.share.util.ShareUtil;

public class SharePopUpViewMediator extends MediatorBase
{
	[Inject]
	public var view:SharePopUpView;

	[Inject]
	public var requestHidePopUpSignal:RequestHidePopUpSignal;

	[Inject]
	public var socialSharingManager:SocialSharingManager;

	private var _util:ShareUtil;
	private var _shareBmd:BitmapData;

	override public function initialize():void {
		super.initialize();

		registerView( view );
		manageStateChanges = false;
		manageMemoryWarnings = false;

		_util = new ShareUtil(socialSharingManager);
		_util.completedSignal.add(onUtilCompleted);

		// From app.
		// ...

		// From view.
		view.popUpWantsToCloseSignal.add( onPopUpWantsToClose );
		view.popUpWantsToShareSignal.add( onPopUpWantsToShare );
	}

	override public function destroy():void {
		super.destroy();
		if(_shareBmd) _shareBmd.dispose();
		_util.completedSignal.remove(onUtilCompleted);
		_util.dispose();
		view.popUpWantsToCloseSignal.remove( onPopUpWantsToClose );
	}

	private function onPopUpWantsToShare(bmd:BitmapData, shareFacebook:Boolean, shareTwitter:Boolean):void {

		if(shareFacebook) _util.addSharer(new FacebookSharer(socialSharingManager));
//		if(shareTwitter) //...

		// Nothing to wait for, close.
		if(_util.numSharers == 0) requestHidePopUpSignal.dispatch();
		else _util.share([_shareBmd = bmd]);
	}

	private function onUtilCompleted():void {
		requestHidePopUpSignal.dispatch();
	}

	private function onPopUpWantsToClose():void {
		requestHidePopUpSignal.dispatch();
	}
}
}
