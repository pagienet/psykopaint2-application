package net.psykosoft.psykopaint2.base.ui.components.list
{

	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/*
	* Provides item renderers for HSnapList.
	* */
	public class HSnapListItemRendererFactory
	{
		private var _itemRenderers:Vector.<DisplayObject>;
		private var _idleItemRenderersForClass:Dictionary; // Contains arrays per item class.

		public function HSnapListItemRendererFactory() {
			super();
			_idleItemRenderersForClass = new Dictionary();
			_itemRenderers = new Vector.<DisplayObject>();
		}

		public function dispose():void {
			// TODO...
		}

		public function getItemRendererOfType( typeClass:Class ):DisplayObject {

			trace( this, "receiving request for item renderer of type: " + typeClass + " ----------------" );

			// Can reuse an available item?
			var availableItemRenderersForThisClass:Vector.<DisplayObject> = _idleItemRenderersForClass[ typeClass ];
			if( availableItemRenderersForThisClass && availableItemRenderersForThisClass.length > 0 ) {
				trace( this, "-> providing stored item renderer" );
				var availableItem:DisplayObject = availableItemRenderersForThisClass[ 0 ];
				availableItemRenderersForThisClass.splice( 0, 1 );
				return availableItem;
			}

			trace( this, "-> creating new item renderer" );

			// Create a new item renderer.
			var renderer:DisplayObject = new typeClass();
			_itemRenderers.push( renderer );

			return renderer;
		}

		public function markItemRendererAsAvailable( itemRendererInstance:DisplayObject ):void {

			// Identify object class.
			var typeClass:Class = Class( getDefinitionByName( getQualifiedClassName( itemRendererInstance ) ) );

			trace( this, "releasing item renderer of type: " + typeClass + " ------------" );

			// Is there an array for this type?
			var availableItemRenderersForThisClass:Vector.<DisplayObject> = _idleItemRenderersForClass[ typeClass ];
			if( !availableItemRenderersForThisClass ) { // No, create one.
				trace( this, "creating new array for type" );
				availableItemRenderersForThisClass = new Vector.<DisplayObject>();
				_idleItemRenderersForClass[ typeClass ] = availableItemRenderersForThisClass;
			}

			// Push object into array for this type.
			availableItemRenderersForThisClass.push( itemRendererInstance );
		}

		public function get itemRenderers():Vector.<DisplayObject> {
			return _itemRenderers;
		}
	}
}
