package net.psykosoft.psykopaint2.core.views.components.combobox {
import com.greensock.TweenLite;
import com.greensock.easing.Back;
import com.greensock.easing.Linear;
import com.greensock.easing.Sine;

import flash.display.Sprite;
import flash.events.Event;

public class SbListView extends Sprite {

	public static const CHANGE:String = "onChange";

	private var _itemViews:Vector.<SbListItemView>
	private var _itemViewContainer:Sprite;

	private var _selectedIndex:int;
	private var _tweenSpeed:Number = 0.35;
	private var _expandedHeight:Number;

	private var _opened:Boolean = false;
	private var _animating:Boolean = false;

	private var _tweenFunction:Function = Linear.easeNone;
	private var _animationObject:Object = { t: 0 };

	//Declared in fla
	public var topImage:Sprite;
	public var bottomImage:Sprite;
	public var bottomImageUpward:Sprite;

	public function SbListView() {
		super();

		_itemViews = new Vector.<SbListItemView>();
		_itemViewContainer = new Sprite();

		topImage.y = 0;
		topImage.x = 4;
		bottomImage.y = 0;
		bottomImage.x = 10;
		bottomImageUpward.x = 3;
		bottomImageUpward.y = 0;

		this.addChild(_itemViewContainer);
	}


	public function removeAll():void {
		for (var i:int = _itemViews.length - 1; i > 0; i--) {
			_itemViews[i].parent.removeChild(_itemViews[i]);

		}
		_itemViews = new Vector.<SbListItemView>();
	}

	public function removeItemAt(index:int):void {
		_itemViews[index].parent.removeChild(_itemViews[index]);
		_itemViews.splice(index, 1);

		caluclateExpandedHeight();

	}

	public function addItemAt(dataObject:Object, index:int):void {
		var listItemVO:SbListItemVO = new SbListItemVO(dataObject);

		listItemVO.odd = (index % 2 == 1) ? true : false;
		var newListItemView:SbListItemView = new SbListItemView();
		newListItemView.setData(listItemVO);
		_itemViews.splice(index, 0, newListItemView);
		_itemViewContainer.addChild(newListItemView);

		caluclateExpandedHeight();
	}

	public function addItem(dataObject:Object):void {

		var listItemVO:SbListItemVO = new SbListItemVO(dataObject);

		listItemVO.odd = (_itemViews.length % 2 == 1) ? true : false;

		var newListItemView:SbListItemView = new SbListItemView();
		newListItemView.setData(listItemVO);
		_itemViews.push(newListItemView);
		_itemViewContainer.addChild(newListItemView);

		caluclateExpandedHeight();
	}


	private function caluclateExpandedHeight():void {
		expand(0);
		animationUpdate();

		//WHEN EVERYTHING IS EXPANDED WE STORE THE EXPANDED HEIGHT
		if (_itemViews.length > 0)
			_expandedHeight = _itemViews[_itemViews.length - 1].y + _itemViews[_itemViews.length - 1].height

		collapse( 0 );
		animationUpdate();
	}


	public function expand(speed:Number = -1):void {
		;

		if (_animating) return;
		_animating = true;

		if (speed == -1) {
			speed = _tweenSpeed;
		}

		TweenLite.killTweensOf(_animationObject);
		TweenLite.to(_animationObject, speed, { t: 1, ease: _tweenFunction, onUpdate: animationUpdate, onComplete: onExpandComplete });
	}

	public function collapse(speed:Number = -1):void {

		if (_animating) return;
		_animating = true;

		dispatchEvent(new Event(SbListView.CHANGE));

		if (speed == -1) {
			speed = _tweenSpeed;
		}

		TweenLite.killTweensOf(_animationObject);
		TweenLite.to(_animationObject, speed, { t: 0, ease: _tweenFunction, onUpdate: animationUpdate, onComplete: onCollapseComplete });
	}

	/* OVERRIDE HEIGHT, ONLY TAKE INTO ACCOUNT THE LISTITEMVIEWS WITHOUT TOP AND BOTTOM */
	override public function get height():Number {
		return _expandedHeight;
	}

	override public function set height(value:Number):void {
		_itemViewContainer.height = value;
		animationUpdate();
	}

	public function  get length():uint {
		return _itemViews.length;
	}

	private function onCollapseComplete():void {
		_opened = false;
		_animating = false;
	}

	private function onExpandComplete():void {
		_opened = true;
		_animating = false;
	}

	private const ITEM_HEIGHT:Number = 33;

	private function animationUpdate():void {

		var yOffset:Number = -_selectedIndex * ITEM_HEIGHT * _animationObject.t;

		for (var i:int = 0; i < _itemViews.length; i++) {

			var currentItemView:SbListItemView = _itemViews[i];

			if( i == _selectedIndex ) {
				currentItemView.scaleY = 1;
			}
			else {
				currentItemView.scaleY = _animationObject.t;
				currentItemView.visible = _animationObject.t > 0;
			}

			currentItemView.y = yOffset + i * ITEM_HEIGHT * _animationObject.t - _animationObject.t;
		}

		topImage.scaleY = _animationObject.t;
		topImage.y = yOffset - topImage.height + 1;

		bottomImage.scaleY = _animationObject.t;
		bottomImageUpward.scaleY = _animationObject.t;

		//IF LAST ITEM IS upward there is a different end
		bottomImage.visible = !currentItemView.getData().odd;
		bottomImageUpward.visible = !bottomImage.visible;

		bottomImage.y = currentItemView.y + currentItemView.height - 1;
		bottomImageUpward.y = currentItemView.y + currentItemView.height - 1;
	}

	public function get expandedHeight():Number {
		return _expandedHeight;
	}

	public function destroy():void {
		//TODO: make sure everything is disposed
	}

	public function get tweenSpeed():Number {
		return _tweenSpeed;
	}

	public function get tweenFunction():Function {
		return _tweenFunction;
	}

	public function get selectedIndex():int {
		return _selectedIndex;
	}

	public function get selectedItem():SbListItemVO {
		return _itemViews[_selectedIndex].getData();
	}
}
}