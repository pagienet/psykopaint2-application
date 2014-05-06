package net.psykosoft.psykopaint2.core.views.popups.share
{

import com.greensock.TweenLite;
import com.greensock.easing.Strong;

import flash.display.MovieClip;

import flash.display.Sprite;
import flash.events.MouseEvent;

import net.psykosoft.psykopaint2.core.views.components.button.IconButtonAlt;
import net.psykosoft.psykopaint2.core.views.components.checkbox.CheckBox;

import net.psykosoft.psykopaint2.core.views.popups.base.PopUpViewBase;

import org.osflash.signals.Signal;

public class SharePopUpView extends PopUpViewBase
{
	// Declared in Flash.
	public var bg:Sprite;
	public var rightSide:Sprite;
	public var facebookChk:CheckBox;
	public var twitterChk:CheckBox;

	private var _rightButton:IconButtonAlt;

	public var popUpWantsToCloseSignal:Signal = new Signal();

	public function SharePopUpView() {
		super();

		_rightButton = rightSide.getChildByName( "btn" ) as IconButtonAlt;
//		_rightButton.labelText = "continue";
		_rightButton.iconType = "continue";
		_rightButton.label.visible = false;
		_rightButton.addEventListener( MouseEvent.CLICK, onRightBtnClick );
		rightSide.visible = false;
	}

	private function onRightBtnClick( event:MouseEvent ):void {
		popUpWantsToCloseSignal.dispatch();
	}

	override protected function onDisabled():void {

		_rightButton.removeEventListener( MouseEvent.CLICK, onRightBtnClick );
		_rightButton.dispose();

		super.onDisabled();
	}

	override public function onBlockerClicked():void {
		popUpWantsToCloseSignal.dispatch();
	}

	// -----------------------
	// Side btn animations.
	// -----------------------

	override public function onAnimatedIn():void {
		animateSideBtnsIn();
	}

	override public function onGoingToAnimateOut():void {
		animateSideBtnsOut();
	}

	private function animateSideBtnsIn():void {
		rightSide.x = 1024 + rightSide.width;
		rightSide.y = 768 + rightSide.height;
		rightSide.visible = true;
		TweenLite.to( rightSide, 0.15, { x: 1024, y: 790, ease: Strong.easeOut } );
	}

	private function animateSideBtnsOut():void {
		TweenLite.to( rightSide, 0.15, { x: 1024 + rightSide.width, y: 768 + rightSide.height, ease: Strong.easeIn, onComplete: onAnimateOutComplete, onCompleteParams: [ rightSide ] } );
	}

	private function onAnimateOutComplete( target:MovieClip ):void {
		target.visible = false;
	}
}
}
