package net.psykosoft.psykopaint2.base.ui.components.list
{

	import flash.display.DisplayObject;
	import flash.utils.describeType;

	import net.psykosoft.psykopaint2.base.ui.components.*;

	import org.osflash.signals.Signal;

	/*
	* An data driven HSnapScroller that adds snap points at the position of each child.
	* */
	public class HSnapList extends HSnapScroller
	{
		private var _dataProvider:Vector.<ISnapListData>;
		private var _itemRendererFactory:HSnapListItemRendererFactory;

		public var itemGap:Number = 15;

		public var rendererAddedSignal:Signal;
		public var rendererRemovedSignal:Signal;

		public function HSnapList() {
			super();
			rendererAddedSignal = new Signal();
			rendererRemovedSignal = new Signal();
			_itemRendererFactory = new HSnapListItemRendererFactory();
		}

		public function setDataProvider( data:Vector.<ISnapListData> ):void {

			// Clean up and set.
			if( _dataProvider ) {
				// TODO: clean up old provider
			}
			_dataProvider = data;

			// Create snap points.
			invalidateContent();
		}

		override public function invalidateContent():void {

			if( !_dataProvider ) return;

			// Create snap points for each data item.
			// Items will remember their associated position.
			var i:uint;
			var numItems:uint = _dataProvider.length;
			var itemData:ISnapListData;
			var itemPositioningMarker:Number = 0;
			for( i = 0; i < numItems; i++ ) {
				itemData = _dataProvider[ i ];
				itemData.itemRendererPosition = itemPositioningMarker + itemData.itemRendererWidth / 2;
				itemPositioningMarker += itemData.itemRendererWidth + itemGap;
				evaluateDimensionsFromItemPositionAndWidth( itemData.itemRendererPosition, itemData.itemRendererWidth );
				evaluateNewSnapPointFromPosition( itemData.itemRendererPosition );
			}

			containEdgeSnapPoints();
			dock();

//			visualizeVisibleDimensions();
//			visualizeContentDimensions();
//			visualizeSnapPoints();
//			visualizeDataPositionsAndDimensions();

			refreshItemRenderers();
		}

		private function visualizeDataPositionsAndDimensions():void {
			var i:uint;
			var len:uint = _dataProvider.length;
			var itemData:ISnapListData;
			_container.graphics.lineStyle( 1, 0xFF0000, 1 );
			for( i = 0; i < len; ++i ) {
				itemData = _dataProvider[ i ];
				var hw:Number = itemData.itemRendererWidth / 2;
				var px:Number = itemData.itemRendererPosition - hw;
				_container.graphics.drawRect( px, 0, itemData.itemRendererWidth, itemData.itemRendererWidth );
			}
		}

		override protected function onUpdate():void {
			refreshItemRenderers();
		}

		private function refreshItemRenderers():void {

			var i:uint;
			var numItems:uint;
			var itemRenderer:DisplayObject;
			var itemData:ISnapListData;

			// Which items should *become* visible?
			numItems = _dataProvider.length;
			var indicesOfItemsThatBecomeVisible:Vector.<uint> = new Vector.<uint>();
			var indicesOfItemsThatBecomeInvisible:Vector.<uint> = new Vector.<uint>();
			for( i = 0; i < numItems; i++ ) {
				itemData = _dataProvider[ i ];
				var shouldBeVisible:Boolean = shouldItemBeVisibleAtCurrentScrollPosition( itemData );
				var isCurrentlyVisible:Boolean = itemData.isDataItemVisible;
				if( !isCurrentlyVisible && shouldBeVisible ) {
//					trace( i + " becoming visible" );
					indicesOfItemsThatBecomeVisible.push( i );
					itemData.isDataItemVisible = true;
				}
				else if( isCurrentlyVisible && !shouldBeVisible ) {
//					trace( i + " becoming invisible" );
					indicesOfItemsThatBecomeInvisible.push( i );
					itemData.isDataItemVisible = false;
				}
			}

			// Decommission item renderers from items that are becoming not visible.
			numItems = indicesOfItemsThatBecomeInvisible.length;
			for( i = 0; i < numItems; i++ ) {

				itemData = _dataProvider[ indicesOfItemsThatBecomeInvisible[ i ] ];

				// Dissociate item renderer from data and mark it as available.
				itemRenderer = itemData.itemRenderer;
				releaseItemRenderer( itemRenderer );
				itemData.itemRenderer = null;

				// Remove from display list.
				_container.removeChild( itemRenderer ); // TODO: do not remove child, just set invisible?
			}

			// Assign renderers to items that are becoming visible.
			numItems = indicesOfItemsThatBecomeVisible.length;
			for( i = 0; i < numItems; i++ ) {

				itemData = _dataProvider[ indicesOfItemsThatBecomeVisible[ i ] ];

				// Retrieve an item renderer.
				itemRenderer = getNewItemRendererForData( itemData );
				itemData.itemRenderer = itemRenderer;

				// Configure renderer from data properties.
				configureItemRendererFromData( itemRenderer, itemData );

				// Add it to display.
				itemRenderer.x = itemData.itemRendererPosition;
				itemRenderer.y = itemData.itemRendererWidth / 2;
				_container.addChild( itemRenderer );
			}
		}

		private function getNewItemRendererForData( data:ISnapListData ):DisplayObject {
			var renderer:DisplayObject = _itemRendererFactory.getItemRendererOfType( data.itemRendererType );
			rendererAddedSignal.dispatch( renderer );
			return renderer;
		}

		private function releaseItemRenderer( renderer:DisplayObject ):void {
			rendererRemovedSignal.dispatch( renderer );
			_itemRendererFactory.markItemRendererAsAvailable( renderer );
		}

		private function configureItemRendererFromData( itemRenderer:DisplayObject, itemData:ISnapListData ):void {

			// Obtain object public interface description in xml.
			var objectDescriptor:XML = describeType( itemData );
			var propertyList:XMLList = objectDescriptor.variable;

			// Sweep the item's data and check if it has properties that the item's renderer also has.
			// If so, set.
			var i:uint;
			var numProperties:uint = propertyList.length();
			for( i = 0; i < numProperties; i++ ) {
				var propertyName:String = propertyList[ i ].@name;
				if( itemRenderer.hasOwnProperty( propertyName ) ) {
					var propertyValue:* = itemData[ propertyName ];
					if( propertyValue ) {
						itemRenderer[ propertyName ] = propertyValue;
					}
				}
			}
		}

		private function shouldItemBeVisibleAtCurrentScrollPosition( itemData:ISnapListData ):Boolean {
			var px:Number = _container.x + itemData.itemRendererPosition;
			var hw:Number = itemData.itemRendererWidth * 0.5;
			return px + hw >= 0 && px - hw <= _visibleWidth;
		}
	}
}
