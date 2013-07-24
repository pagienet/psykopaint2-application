package net.psykosoft.psykopaint2.base.ui.components.list
{

	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class HSnapListItemRendererFactory
	{
		private var _idleItemRenderersForClass:Dictionary; // Contains arrays per item class.

		public function HSnapListItemRendererFactory() {
			super();
			_idleItemRenderersForClass = new Dictionary();
		}

		public function dispose():void {
			// TODO...
		}

		public function getItemRendererOfType( typeClass:Class ):DisplayObject {

			// Can reuse an available item?
			var availableItemRenderersForThisClass:Vector.<DisplayObject> = _idleItemRenderersForClass[ typeClass ];
			if( availableItemRenderersForThisClass && availableItemRenderersForThisClass.length > 0 ) {
				var availableItem:DisplayObject = availableItemRenderersForThisClass[ 0 ];
				availableItemRenderersForThisClass.splice( 0, 1 );
				return availableItem;
			}

			// No? Then create a new one.
			return new typeClass();
		}

		public function markItemRendererAsAvailable( itemRendererInstance:DisplayObject ):void {
			var typeClass:Class = Class( getDefinitionByName( getQualifiedClassName( itemRendererInstance ) ) );
			var availableItemRenderersForThisClass:Vector.<DisplayObject> = _idleItemRenderersForClass[ typeClass ];
			if( !availableItemRenderersForThisClass ) {
				availableItemRenderersForThisClass = new Vector.<DisplayObject>();
				_idleItemRenderersForClass[ typeClass ] = availableItemRenderersForThisClass;
			}
			availableItemRenderersForThisClass.push( itemRendererInstance );
		}
	}
}
