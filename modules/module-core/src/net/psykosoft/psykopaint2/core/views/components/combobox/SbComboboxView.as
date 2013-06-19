package net.psykosoft.psykopaint2.core.views.components.combobox {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import net.psykosoft.psykopaint2.base.utils.DraggableDecorator;

public class SbComboboxView extends Sprite {

	private var _listView:SbListView;
	private var _listViewContainer:Sprite;
	private var _dragDecorator:DraggableDecorator;
	private var _selectedIndex:int;
	private var _mouseIsDown:Boolean;

	public function SbComboboxView() {
		super();

		_listView = new SbListView();
		_listViewContainer = new Sprite();

		_listViewContainer.x = 43; // TODO: remove unneeded layer
		_listViewContainer.y = 20;

		_listViewContainer.addChild(_listView);
		this.addChildAt(_listViewContainer, 0);

		_dragDecorator = new DraggableDecorator(_listView, new Rectangle(0, 0, _listView.width, _listView.height));
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onChangeList(e:Event):void {
		_selectedIndex = _listView.selectedIndex;
		dispatchEvent(new Event(Event.CHANGE));
	}

	public function addItem(params:Object):void {
		_listView.addItem(params);
		//UPDATE DRAG DECORATOR
		_dragDecorator.setBounds(new Rectangle(0, -_listView.height, 0, _listView.height + 10));
	}


	public function addItemAt(params:Object, index:int):void {
		_listView.addItemAt(params, index);
		//UPDATE DRAG DECORATOR
		_dragDecorator.setBounds(new Rectangle(0, -_listView.height, 0, _listView.height + 10));
	}

	public function removeItemAt(index:int):void {
		_listView.removeItemAt(index);
		//UPDATE DRAG DECORATOR
		_dragDecorator.setBounds(new Rectangle(0, -_listView.height, 0, _listView.height + 10));
	}

	public function removeAll():void {
		_listView.removeAll();
		//UPDATE DRAG DECORATOR
		_dragDecorator.setBounds(new Rectangle(0, -_listView.height, 0, _listView.height + 10));
	}

	public function get selectedIndex():int {
		return _selectedIndex;
	}

	public function get selectedItem():SbListItemVO {
		return _listView.selectedItem;
	}

	// ---------------------------------------------------------------------
	// Listeners.
	// ---------------------------------------------------------------------

	private function onMouseDownEvent(e:MouseEvent):void {
		_mouseIsDown = true;
		_listView.expand();
		_dragDecorator.shiftPosition += _listView.selectedIndex * _listView.height / _listView.length;
	}


	private function onMouseUp(event:MouseEvent):void {
		if( !_mouseIsDown ) return;
		_mouseIsDown = false;
		_listView.collapse();
	}

	private function onAddedToStage(event:Event):void {
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		_listView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownEvent);
		_listView.addEventListener(SbListView.CHANGE, onChangeList);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp)
	}
}
}
