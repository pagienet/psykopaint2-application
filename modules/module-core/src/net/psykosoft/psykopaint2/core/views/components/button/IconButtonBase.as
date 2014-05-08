package net.psykosoft.psykopaint2.core.views.components.button
{

import flash.events.MouseEvent;

import net.psykosoft.psykopaint2.base.ui.components.NavigationButton;

public class IconButtonBase extends NavigationButton
{
	public function IconButtonBase() {
		super();
	}

	override public function set selected( value:Boolean ):void {
		super.selected = value;
		_icon.fold = !value;
	}

	override protected function onStageMouseUp( event:MouseEvent ):void {
		super.onStageMouseUp(event);
		if( enabled && !_selected ) {
			_icon.fold = true;
		}
	}

	override protected function onThisMouseDown( event:MouseEvent ):void {
		super.onThisMouseDown(event);
		if( enabled ) {
			_icon.fold = false;
		}
	}
}
}
