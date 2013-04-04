package net.psykosoft.psykopaint2.app.view.selectimage
{

	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.data.ListCollection;
	import feathers.layout.TiledRowsLayout;

	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;
	import net.psykosoft.psykopaint2.app.view.renderers.ImageListItemRenderer;

	import org.osflash.signals.Signal;

	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/*
	* Selects an image from the user photos or from packaged images.
	* TODO: change mode to use sprite sheets for thumbs so this is compatible with the user photos extension.
	* */
	public class SelectImageView extends StarlingViewBase
	{
		private var _list:List;
		private var _listLayout:TiledRowsLayout;
		private var _thumbNames:Vector.<String>;
		private var _dataProvider:ListCollection;

		public var listSelectedItemChangedSignal:Signal;

		public function SelectImageView() {
			super();
			listSelectedItemChangedSignal = new Signal( String ); // Item name or id.
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {

			_listLayout = new TiledRowsLayout();
			_listLayout.gap = 10;
			_listLayout.paddingLeft = _listLayout.paddingRight = _listLayout.paddingTop = 10;
			_listLayout.paddingBottom = 150;
			_listLayout.paging = TiledRowsLayout.PAGING_HORIZONTAL;
			_listLayout.useSquareTiles = false;
			_listLayout.tileHorizontalAlign = TiledRowsLayout.TILE_HORIZONTAL_ALIGN_CENTER;
			_listLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_CENTER;

			_list = new List();
			_list.layout = _listLayout;
			_list.scrollerProperties.snapToPages = true;
			_list.scrollerProperties.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_NONE;
			_list.scrollerProperties.horizontalScrollPolicy = Scroller.SCROLL_POLICY_ON;
			_list.itemRendererType = ImageListItemRenderer;
			_list.addEventListener( Event.CHANGE, onListChange );
			_list.width = stage.stageWidth;
			_list.height = stage.stageHeight;
			_list.validate();
			_list.dataProvider = _dataProvider = new ListCollection();
			addChild( _list );

			_thumbNames = new Vector.<String>();
		}

		override protected function onDisabled():void {

			if( _list ) {
				removeChild( _list );
			}

		}

		override protected function onDispose():void {

			if( _listLayout ) {
				_listLayout = null;
			}

			if( _list ) {
				_list.dispose();
				_list = null;
			}

			if( _thumbNames ) {
				_thumbNames = null;
			}

			listSelectedItemChangedSignal = null;

		}

// ---------------------------------------------------------------------
		// Public.
		// ---------------------------------------------------------------------

		public function displayThumbs( thumbs:TextureAtlas ):void {

			trace( this, "displaying thumbs from texture atlas: " + thumbs );

			var textures:Vector.<Texture> = thumbs.getTextures();
			_thumbNames = _thumbNames.concat( thumbs.getNames() );

			for( var i:uint; i < textures.length; i++ ) {
				_dataProvider.push( { texture: textures[ i ] } );
			}

			_list.dataProvider = _dataProvider; // TODO: needed?
			_list.validate();
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function onListChange( event:Event ):void {
			var itemName:String = _thumbNames[ _list.selectedIndex ];
			listSelectedItemChangedSignal.dispatch( itemName );
		}
	}
}
