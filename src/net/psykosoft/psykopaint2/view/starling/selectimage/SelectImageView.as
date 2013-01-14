package net.psykosoft.psykopaint2.view.starling.selectimage
{

	import com.junkbyte.console.Cc;

	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.TiledRowsLayout;

	import flash.display.BitmapData;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.view.starling.base.StarlingViewBase;

	import starling.core.Starling;

	import starling.display.Image;
	import starling.display.Quad;
	import starling.textures.Texture;

	public class SelectImageView extends StarlingViewBase
	{
		private var _thumbTextures:Vector.<Texture>;
		private var _list:List;
		private var _listLayout:TiledRowsLayout;

		public function SelectImageView() {
			super();
		}

		override protected function onStageAvailable():void {

			/*var label:Label = new Label();
			label.text = "Displays images the user can load to start painting on.\nPlease select an image bank source.";
			addChild( label );
			label.validate();
			label.x = stage.stageWidth / 2 - label.width / 2;
			label.y = stage.stageHeight / 2 - label.height / 2;*/

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
			addChild( _list );

			super.onStageAvailable();
		}

		protected function tileListItemRendererFactory():IListItemRenderer {
			const renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
//			renderer.labelFunction = tileListLabelFunction;
			renderer.labelField = "label";
			renderer.iconSourceField = "texture";
			renderer.iconPosition = Button.ICON_POSITION_TOP;
			return renderer;
		}

		private function tileListLabelFunction( item:Object ):String {
			return "";
		}

		public function displayThumbs( bitmapDatas:Vector.<BitmapData> ):void {

			if( _thumbTextures ) {
				disposeImages();
			}

			Cc.info( this, "loading bitmap datas: " + bitmapDatas.length );

			// Produce textures.
			_thumbTextures = new Vector.<Texture>();
			var dataProvider:ListCollection = new ListCollection();
			for( var i:uint; i < bitmapDatas.length; i++ ) {
				var bmd:BitmapData = bitmapDatas[ i ];
				var texture:Texture = Texture.fromBitmapData( bmd, false, false, Starling.contentScaleFactor );
				Cc.info( this, "creating texture: " + texture );
				_thumbTextures.push( texture );
				dataProvider.push( { label: " ", texture: texture } );
				// TODO: having no label appears to damage the list item size measurements
			}

			Cc.info( this, "setting list data provider: " + dataProvider.length );
			_list.dataProvider = dataProvider;
			_list.validate();

			Cc.info( this, "done" );

			// TODO: view feathers tile list example to display the images
		}

		override protected function onLayout():void {

			_list.width = stage.stageWidth;
			_list.height = stage.stageHeight;
			_list.validate();
			
			super.onLayout();
		}

		private function disposeImages():void {

			Cc.info( this, "disposing old textures." );

			for( var i:uint; i < _thumbTextures.length; i++ ) {
				var texture:Texture = _thumbTextures[ i ];
				texture.dispose();
			}

			_thumbTextures = new Vector.<Texture>();
		}
	}
}
