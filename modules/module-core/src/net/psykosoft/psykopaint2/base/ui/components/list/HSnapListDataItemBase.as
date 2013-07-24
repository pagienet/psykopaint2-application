package net.psykosoft.psykopaint2.base.ui.components.list
{

	import flash.display.DisplayObject;

	public class HSnapListDataItemBase
	{
		private var _itemRenderer:DisplayObject;
		private var _itemRendererType:Class;
		private var _itemRendererWidth:Number;
		private var _itemRendererPosition:Number;
		private var _isDataItemVisible:Boolean; // TODO: remove

		public function HSnapListDataItemBase() {
			super();
		}

		public function get itemRendererWidth():Number {
			return _itemRendererWidth;
		}

		public function set itemRendererWidth( value:Number ):void {
			_itemRendererWidth = value;
		}

		public function get itemRendererPosition():Number {
			return _itemRendererPosition;
		}

		public function set itemRendererPosition( value:Number ):void {
			_itemRendererPosition = value;
		}

		public function get isDataItemVisible():Boolean {
			return _isDataItemVisible;
		}

		public function set isDataItemVisible( value:Boolean ):void {
			_isDataItemVisible = value;
		}

		public function get itemRenderer():DisplayObject {
			return _itemRenderer;
		}

		public function set itemRenderer( value:DisplayObject ):void {
			_itemRenderer = value;
		}

		public function get itemRendererType():Class {
			return _itemRendererType;
		}

		public function set itemRendererType( value:Class ):void {
			_itemRendererType = value;
		}
	}
}
