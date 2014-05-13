package net.psykosoft.psykopaint2.core.managers.social.sharers
{

import net.psykosoft.psykopaint2.core.managers.social.SocialSharingManager;

public class CompositeSharer extends SharerBase
{
	private var _sharers:Vector.<SharerBase>;

	private var _activeSharer:SharerBase;
	private var _activeSharerIndex:int = -1;
	private var _successes:Array;
	private var _failures:Array;

	public function CompositeSharer(manager:SocialSharingManager) {
		super(manager);
		_sharers = new Vector.<SharerBase>();
	}

	public function addSharer(sharer:SharerBase):void {
		_sharers.push(sharer);
	}

	public function get numSharers():uint {
		return _sharers.length;
	}

	public function get succeededSharerNames():Array {
		return _successes;
	}

	public function get failedSharerNames():Array {
		return _failures;
	}

	override public function share(content:Array):void {
		super.share(content);
		_successes = [];
		_failures = [];
		shareNextOrComplete();
	}

	private function shareNextOrComplete():void {
		_activeSharerIndex++;
		if(_activeSharerIndex < _sharers.length) {
			_activeSharer = _sharers[_activeSharerIndex];
			toggleListeners(true);
			_activeSharer.share(_contentToBeShared);
		}
		else {
			// This sharer never fails.
			completedSignal.dispatch();
		}
	}

	private function onActiveSharerCompleted():void {
		toggleListeners(false);
		_successes.push(_activeSharer.sharerName);
		shareNextOrComplete();
	}

	private function onActiveSharerFailed():void {
		toggleListeners(false);
		_failures.push(_activeSharer.sharerName);
		shareNextOrComplete();
	}

	private function onActiveSharerAborted():void {
		toggleListeners(false);
		_failures.push(_activeSharer.sharerName);
		shareNextOrComplete();
	}

	private function toggleListeners(on:Boolean):void {
		if(on) {
			_activeSharer.completedSignal.add(onActiveSharerCompleted);
			_activeSharer.failedSignal.add(onActiveSharerFailed);
			_activeSharer.abortedSignal.add(onActiveSharerAborted);
		}
		else {
			_activeSharer.completedSignal.remove(onActiveSharerCompleted);
			_activeSharer.failedSignal.remove(onActiveSharerFailed);
			_activeSharer.abortedSignal.remove(onActiveSharerAborted);
		}
	}

	override public function dispose():void {
		for(var i:uint; i < _sharers.length; i++) {
			var sharer:SharerBase = _sharers[i];
			sharer.dispose();
		}
		super.dispose();
	}
}
}
