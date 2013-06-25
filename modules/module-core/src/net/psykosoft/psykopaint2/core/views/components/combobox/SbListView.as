package net.psykosoft.psykopaint2.core.views.components.combobox
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;

	import flash.display.Sprite;
	import flash.events.Event;

	public class SbListView extends Sprite
	{
		public static const CHANGE:String = "onChange";

		private var _itemViews:Vector.<SbListItemView>
		private var _itemViewContainer:Sprite;
		private var _selectedIndex:int = 0;
		private var _open:Boolean = false;
		private var _animating:Boolean = false;
		private var _animationObject:Object = { t: 0 };

		private const ITEM_HEIGHT:Number = 33;
		private const TWEEN_TIME:Number = 0.25;
		private const TWEEN_FUNCTION:Function = Expo.easeInOut;

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

			this.addChild( _itemViewContainer );
		}

		public function destroy():void {
			//TODO: make sure everything is disposed
		}

		public function removeAll():void {
			for( var i:int = _itemViews.length - 1; i > 0; i-- ) {
				_itemViews[i].parent.removeChild( _itemViews[i] );

			}
			_itemViews = new Vector.<SbListItemView>();
		}

		public function removeItemAt( index:int ):void {
			_itemViews[index].parent.removeChild( _itemViews[index] );
			_itemViews.splice( index, 1 );
		}

		public function addItemAt( dataObject:Object, index:int ):void {
			var listItemVO:SbListItemVO = new SbListItemVO( dataObject );
			listItemVO.odd = (index % 2 == 1) ? true : false;
			var newListItemView:SbListItemView = new SbListItemView();
			newListItemView.setData( listItemVO );
			_itemViews.splice( index, 0, newListItemView );
			_itemViewContainer.addChildAt( newListItemView, 0 );
		}

		public function addItem( dataObject:Object ):void {
			var listItemVO:SbListItemVO = new SbListItemVO( dataObject );
			listItemVO.odd = (_itemViews.length % 2 == 1) ? true : false;
			var newListItemView:SbListItemView = new SbListItemView();
			newListItemView.setData( listItemVO );
			_itemViews.push( newListItemView );
			_itemViewContainer.addChildAt( newListItemView, 0 );
		}

		public function expand():void {
			_animating = true;
			TweenLite.killTweensOf( _animationObject );
			TweenLite.to( _animationObject, TWEEN_TIME, { t: 1, ease: TWEEN_FUNCTION, onUpdate: animationUpdate, onComplete: onExpandComplete } );
		}

		public function collapse():void {
			_animating = true;
			dispatchEvent( new Event( SbListView.CHANGE ) );
			TweenLite.killTweensOf( _animationObject );
			TweenLite.to( _animationObject, TWEEN_TIME, { t: 0, ease: TWEEN_FUNCTION, onUpdate: animationUpdate, onComplete: onCollapseComplete } );
		}

		override public function set height( value:Number ):void {
			_itemViewContainer.height = value;
			animationUpdate();
		}

		public function  get numItems():uint {
			return _itemViews.length;
		}

		private function onCollapseComplete():void {
			_open = false;
			_animating = false;
		}

		private function onExpandComplete():void {
			_open = true;
			_animating = false;
		}

		private function animationUpdate():void {

			var i:int;
			var start:uint;
			var end:uint;
			var marker:Number;
			var currentItemView:SbListItemView = _itemViews[ 0 ];

			var t:Number = _animationObject.t;
			var squeeze:Number = t;

			// Sweep before selected index.
			start = _selectedIndex - 1;
			end = 0;
			marker = 0;
			for( i = start; i >= end; i-- ) {
				currentItemView = _itemViews[ i ];
				currentItemView.scaleY = t;
				currentItemView.visible = t > 0;
				marker -= currentItemView.height - squeeze;
				currentItemView.y = marker;
			}

			topImage.scaleY = t;
			topImage.y = currentItemView.y - topImage.height + squeeze;

			// Sweep after selected index.
			start = _selectedIndex + 1;
			end = _itemViews.length;
			marker = ITEM_HEIGHT;
			for( i = start; i < end; i++ ) {
				currentItemView = _itemViews[ i ];
				currentItemView.scaleY = t;
				currentItemView.visible = t > 0;
				currentItemView.y = marker - squeeze;
				marker += currentItemView.height;
			}

			if( _selectedIndex == end - 1 ) currentItemView = _itemViews[ _selectedIndex ];

			bottomImage.scaleY = bottomImageUpward.scaleY = t;
			bottomImage.visible = !currentItemView.getData().odd;
			bottomImageUpward.visible = !bottomImage.visible;
			bottomImage.y = bottomImageUpward.y = currentItemView.y + currentItemView.height - squeeze;
		}

		public function get selectedIndex():int {
			return _selectedIndex;
		}

		public function set selectedIndex( value:int ):void {
			_selectedIndex = value;
			var currentItemView:SbListItemView = _itemViews[ _selectedIndex ];
			currentItemView.visible = true;
			currentItemView.y = 0;
			currentItemView.scaleY = 1;
			animationUpdate();
		}

		public function get selectedItem():SbListItemVO {
			return _itemViews[_selectedIndex].getData();
		}

		public function get animating():Boolean {
			return _animating;
		}

		public function get expandedHeight():Number {
			return _itemViews.length * ITEM_HEIGHT;
		}

		public function get itemHeight():Number {
			return ITEM_HEIGHT;
		}

		public function get tweenFunction():Function {
			return TWEEN_FUNCTION;
		}

		public function get tweenTime():Number {
			return TWEEN_TIME;
		}
	}
}