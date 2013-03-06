package net.psykosoft.psykopaint2.app.view.selectimage
{

	import feathers.controls.Button;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.TiledRowsLayout;

	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;

	import org.osflash.signals.Signal;

	import starling.display.Quad;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/*
	* Selects an image from the user photos or from packaged images.
	* TODO: change mode to use sprite sheets for thumbs so this is compatible with the user photos extension.
	* */
	public class SelectThumbView extends StarlingViewBase
	{
		private var _list:List;
		private var _listLayout:TiledRowsLayout;
		private var _thumbNames:Vector.<String>;

		public var listSelectedItemChangedSignal:Signal;

		public function SelectThumbView() {
			super();
			listSelectedItemChangedSignal = new Signal( String ); // Item name or id.
		}

		override protected function onStageAvailable():void {

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
			_list.backgroundSkin = new Quad( 100, 100, 0x222222 );
			_list.scrollerProperties.snapToPages = true;
			_list.scrollerProperties.scrollBarDisplayMode = Scroller.SCROLL_BAR_DISPLAY_MODE_NONE;
			_list.scrollerProperties.horizontalScrollPolicy = Scroller.SCROLL_POLICY_ON;
			_list.itemRendererFactory = tileListItemRendererFactory;
			_list.addEventListener( Event.CHANGE, onListChange );
			addChild( _list );

			super.onStageAvailable();
		}

		protected function tileListItemRendererFactory():IListItemRenderer {
			const renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
			renderer.labelField = "label";
			renderer.iconSourceField = "texture";
			renderer.iconPosition = Button.ICON_POSITION_TOP;
			return renderer;
		}

		public function displayThumbs( thumbs:TextureAtlas ):void {

			var textures:Vector.<Texture> = thumbs.getTextures();
			_thumbNames = thumbs.getNames();

			var dataProvider:ListCollection = new ListCollection();
			for( var i:uint; i < textures.length; i++ ) {
				dataProvider.push( { label: " ", texture: textures[ i ] } );
				// TODO: having no label appears to damage the list item size measurements, adding an empty label for now
			}

			_list.dataProvider = dataProvider;
			_list.validate();
		}

		private function onListChange( event:Event ):void {
			var itemName:String = _thumbNames[ _list.selectedIndex ];
			listSelectedItemChangedSignal.dispatch( itemName );
		}

		override protected function onLayout():void {

			_list.width = stage.stageWidth;
			_list.height = stage.stageHeight;
			_list.validate();
			
			super.onLayout();
		}

		public function clearThumbs():void {

			_list.dataProvider = new ListCollection();
			_thumbNames = null;

		}
	}
}
