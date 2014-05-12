package net.psykosoft.psykopaint2.core.views.popups.quickshare
{

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;
import net.psykosoft.psykopaint2.core.signals.RequestHidePopUpSignal;
import net.psykosoft.psykopaint2.core.views.base.MediatorBase;
import net.psykosoft.psykopaint2.core.managers.social.sharers.FacebookSharer;
import net.psykosoft.psykopaint2.core.managers.social.sharers.CompositeSharer;
import net.psykosoft.psykopaint2.core.managers.social.sharers.TwitterSharer;

public class QuickSharePopUpViewMediator extends MediatorBase
{
	[Inject]
	public var view:QuickSharePopUpView;

	[Inject]
	public var requestHidePopUpSignal:RequestHidePopUpSignal;

	[Inject]
	public var socialSharingManager:SocialSharingManager;

	private var _sharer:CompositeSharer;

	override public function initialize():void {
		super.initialize();

		registerView( view );
		manageStateChanges = false;
		manageMemoryWarnings = false;

		_sharer = new CompositeSharer(socialSharingManager);
		_sharer.completedSignal.add(onUtilCompleted);

		// From app.
		// ...

		// From view.
		view.popUpWantsToCloseSignal.add( onPopUpWantsToClose );
		view.popUpWantsToShareSignal.add( onPopUpWantsToShare );
	}

	override public function destroy():void {
		super.destroy();
		if(view.bmd) view.bmd.dispose();
		_sharer.completedSignal.remove(onUtilCompleted);
		_sharer.dispose();
		view.popUpWantsToCloseSignal.remove( onPopUpWantsToClose );
	}

	private function onPopUpWantsToShare():void {

		if(view.facebookChk.selected) _sharer.addSharer(new FacebookSharer(socialSharingManager));
		if(view.twitterChk.selected) _sharer.addSharer(new TwitterSharer(socialSharingManager));

		// Nothing to wait for, close.
		if(_sharer.numSharers == 0) requestHidePopUpSignal.dispatch();
		else _sharer.share([view.tf.text, view.bmd]);
	}

	private function onUtilCompleted():void {
		requestHidePopUpSignal.dispatch();
	}

	private function onPopUpWantsToClose():void {
		requestHidePopUpSignal.dispatch();
	}
}
}
