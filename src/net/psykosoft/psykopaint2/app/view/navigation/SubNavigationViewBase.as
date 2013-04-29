package net.psykosoft.psykopaint2.app.view.navigation
{

	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import net.psykosoft.psykopaint2.app.config.Settings;
	import net.psykosoft.psykopaint2.app.view.base.StarlingViewBase;
	import net.psykosoft.psykopaint2.app.view.components.buttons.FooterNavButton;
	import net.psykosoft.psykopaint2.app.view.components.label.PaperHeaderLabel;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonDefinitionVO;
	import net.psykosoft.psykopaint2.ui.extensions.buttongroups.vo.ButtonGroupDefinitionVO;
	import net.psykosoft.psykopaint2.ui.theme.Psykopaint2Ui;
	import net.psykosoft.psykopaint2.ui.theme.data.ButtonSkinType;

	import org.osflash.signals.Signal;

	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	public class SubNavigationViewBase extends StarlingViewBase
	{
		private var _scrollContainer:ScrollContainer;
		private var _headerLabel:PaperHeaderLabel;
		private var _title:String;
		private var _frontLayer:Sprite; // TODO: do we still need layers given that the edge buttons have been moved out of this abstract class?
		private var _backLayer:Sprite;
		private var _navigation:NavigationView;
		private var _behavesAsList:Boolean;
		private var _selectedMarker:Image;
		private var _buttonFromLabel:Dictionary;

		public var buttonPressedSignal:Signal;

		public function SubNavigationViewBase( title:String = "" ) {
			super();
			buttonPressedSignal = new Signal();
			_title = title;
			trace( this, "sub-navigation view created: " + _title );
		}

		public function changeTitle( value:String ):void {
			_title = value;
			if( _headerLabel ) {
				_headerLabel.setLabel( _title );
			}
		}

		// ---------------------------------------------------------------------
		// Overrides.
		// ---------------------------------------------------------------------

		override protected function onEnabled():void {

			addChild( _backLayer = new Sprite() );
			addChild( _frontLayer = new Sprite() );

			_headerLabel = new PaperHeaderLabel();
			_headerLabel.addEventListener( Event.RESIZE, onHeaderResized );
			_headerLabel.setLabel(_title);
			_frontLayer.addChild( _headerLabel );
			_headerLabel.x = stage.stageWidth / 2 - _headerLabel.width / 2;
			_headerLabel.y = -_headerLabel.height / 2+20;
		}

		override protected function onDisabled():void {

			clearCenterButtons();

			if( _headerLabel ) {
				_frontLayer.removeChild( _headerLabel );
			}

			if( _frontLayer ) {
				removeChild( _frontLayer );
			}

			if( _backLayer ) {
				removeChild( _backLayer );
			}

			if( _selectedMarker ) {
				removeChild( _selectedMarker );
			}
		}

		override protected function onDispose():void {

			if( _headerLabel ) {
				_headerLabel.dispose();
				_headerLabel = null;
			}

			if( _frontLayer ) {
				_frontLayer.dispose();
				_frontLayer = null;
			}

			if( _backLayer ) {
				_backLayer.dispose();
				_backLayer = null;
			}

			if( _selectedMarker ) {
				_selectedMarker.dispose();
				_selectedMarker.texture.dispose();
				_selectedMarker = null;
			}

			if( _buttonFromLabel ) {
				_buttonFromLabel = null;
			}

		}

		// -----------------------------------------------------------------------------------------------------------------------
		// Setting center buttons.
		// -----------------------------------------------------------------------------------------------------------------------

		public function setNavigation( navigation:NavigationView ):void {
			_navigation = navigation;
		}

		protected function setLeftButton( textureID:String,label:String ):void {
			_navigation.setLeftButton(textureID, label );
		}

		protected function setRightButton(textureID:String, label:String ):void {
			_navigation.setRightButton(textureID, label );
		}

		protected function getTextureFromId( value:String ):Texture {
			return Psykopaint2Ui.instance.footerAtlas.getTexture( value );
		}

		protected function setCenterButtons( definition:ButtonGroupDefinitionVO, behavesAsList:Boolean = false, scrollOutLeftGap:Boolean = false ):void {

			_behavesAsList = behavesAsList;

			_buttonFromLabel = new Dictionary();

			// Scroll capable container.
			_scrollContainer = new ScrollContainer();
//			_scrollContainer.backgroundSkin = new Quad( 100, 100, 0x222222 ); // Uncomment for visual debugging.
			_scrollContainer.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
			_scrollContainer.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_scrollContainer.height = Settings.NAVIGATION_AREA_CONTENT_HEIGHT;
			_backLayer.addChild( _scrollContainer );

			// Add buttons to the container.
			var inflate:Number = 150;
			var accumulatedContentWidth:Number = inflate;
			var len:uint = definition.buttonVOArray.length;
			var gap:Number = 15;
			for( var i:uint = 0; i < len; i++ ) {

				var vo:ButtonDefinitionVO = definition.buttonVOArray[ i ];
				var subButton:FooterNavButton = new FooterNavButton( vo.texture , vo.label, ButtonSkinType.LABEL );
				subButton.addEventListener( Event.TRIGGERED, onButtonTriggered );
				subButton.x = inflate + ( subButton.width + gap ) * i;
				subButton.y = 30;

				_buttonFromLabel[ vo.label ] = subButton;
				
				accumulatedContentWidth += subButton.width;
				if( i != len - 1 ) {
					accumulatedContentWidth += gap;
				}
				else if( i == len - 1 ) {
					accumulatedContentWidth += inflate;
				}
				_scrollContainer.addChild( subButton );
			}

			// Ensure that the rightmost gap is applied.
			var contentWidthEnforcer:Sprite = new Sprite();
			contentWidthEnforcer.x = accumulatedContentWidth;
			_scrollContainer.addChild( contentWidthEnforcer );

			// Center the container.
			if( accumulatedContentWidth < 1024 ) {
				_scrollContainer.width = accumulatedContentWidth;
			}
			else {
				_scrollContainer.width = 1024;
			}
			_scrollContainer.x = 1024 / 2 - _scrollContainer.width / 2;

			// TODO: this is kinda hardcoded, does not produce exact centering and will most likely produce bad results with
			// button counts other than the one found in the settings sub-nav
			if( scrollOutLeftGap ) {
				_scrollContainer.horizontalScrollPosition += inflate - 2 * gap;
			}

			if( behavesAsList ) {
				notifyButtonPress( definition.buttonVOArray[ 0 ].label );
			}
		}

		public function clearCenterButtons():void {

			if( _scrollContainer ) {

				// Kill children.
				while( _scrollContainer.numChildren > 0 ) {
					var child:FooterNavButton = _scrollContainer.getChildAt( 0 ) as FooterNavButton;
					_scrollContainer.removeChildAt( 0 );
					if( child ) {
						// TODO: check if working
						child.removeEventListener( Event.TRIGGERED, onButtonTriggered );
						child.dispose();
						child = null;
					}
				}

				// Kill container.
				_backLayer.removeChild( _scrollContainer );
				_scrollContainer.dispose();
				_scrollContainer = null;
			}
		}

		public function notifyButtonPress( buttonLabel:String ):void {

			// Notify.
			buttonPressedSignal.dispatch( buttonLabel );

			// Update selected marker?
			if( _behavesAsList ) {

				var button:FooterNavButton = _buttonFromLabel[ buttonLabel ];
				if( !button ) return;

				// Need to initialize marker?
				if( !_selectedMarker ) {

					// TODO: implement real graphic, using dummy graphic for now because the provided one lacks necessary transparency
					var dummyBmd:BitmapData = new BitmapData( button.width, button.height, true, 0 );
					_selectedMarker = new Image( Texture.fromBitmapData( new BitmapData( button.width, button.height, true, 0x6600FF00 ) ) );
					dummyBmd.dispose();
					_scrollContainer.addChild( _selectedMarker );
				}

				_selectedMarker.x = button.x;
				_selectedMarker.y = button.y;

			}
		}

		// ---------------------------------------------------------------------
		// Protected.
		// ---------------------------------------------------------------------

		protected function onButtonTriggered( event:Event ):void {
//			trace( this, "button triggered" );
			var button:FooterNavButton = event.currentTarget as FooterNavButton;
			notifyButtonPress( button.label );
		}

		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------

		private function onHeaderResized( event:Event ):void {
			trace("[SubNavigationView] onHeaderResized");
			
			_headerLabel.x = stage.stageWidth / 2 - _headerLabel.width / 2;
			_headerLabel.y = -_headerLabel.height / 2+20;
		}
	}
}
