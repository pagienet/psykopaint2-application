package net.psykosoft.psykopaint2.book.views.book.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.textures.BitmapTexture;

	import flash.display.Stage;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.utils.ui.ScrollInteractionManager;
	import net.psykosoft.psykopaint2.base.utils.ui.SnapPositionManager;
	import net.psykosoft.psykopaint2.book.views.book.content.BookDataProviderBase;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	public class Book extends ObjectContainer3D
	{
		private var _pageWidth:uint;
		private var _pageHeight:uint;
		private var _positionManager:SnapPositionManager;
		private var _interactionManager:ScrollInteractionManager;
		private var _middlePage:Page;
		private var _leftPage:Page;
		private var _rightPage:Page;
		private var _dataProvider:BookDataProviderBase;
		private var _numSnapPoints:uint;
		private var _leftPageBackSheetIndex:int;

		private const SNAP_POINT_SPACING:uint = 100;

		// TODO: remove traces and cleanup, also in related classes

		public function Book( stage:Stage, width:Number, height:Number ) {
			super();

			_pageWidth = width;
			_pageHeight = height;

			_positionManager = new SnapPositionManager();
			_positionManager.minimumThrowingSpeed = 10;
			_positionManager.frictionFactor = 0.75;
//			_positionManager.edgeContainmentFactor = 0.01; // TODO: analyze usage of this

			_interactionManager = new ScrollInteractionManager( _positionManager );
			_interactionManager.scrollInputMultiplier = 0.75 / CoreSettings.GLOBAL_SCALING;
			_interactionManager.throwInputMultiplier = 1 / CoreSettings.GLOBAL_SCALING;
			_interactionManager.stage = stage;
			_interactionManager.useDetailedDelta = false;

			addChild( _leftPage = new Page( width, height ) );
			addChild( _rightPage = new Page( width, height ) );
			addChild( _middlePage = new Page( width, height ) );

			_leftPage.name = "leftPage";
			_rightPage.name = "rightPage";
			_middlePage.name = "middlePage";

			_leftPage.mouseEnabled = _rightPage.mouseEnabled = _middlePage.mouseEnabled = true;
			_leftPage.mouseChildren = _rightPage.mouseChildren = _middlePage.mouseChildren = true;
			_leftPage.addEventListener( MouseEvent3D.MOUSE_UP, onPageMouseUp );
			_rightPage.addEventListener( MouseEvent3D.MOUSE_UP, onPageMouseUp );
			_middlePage.addEventListener( MouseEvent3D.MOUSE_UP, onPageMouseUp );

			// The position of these pages never moves, instead, their content changes.
			// 0 degrees is a page fully on the right side.
			// 180 degrees ia a page fully on the left side.
			// _activePage will move and always be between 0 and 180 degrees.
			_leftPage.flipAngle = 180;
			_rightPage.flipAngle = 0;

			// A little offset on static pages to avoid z-fighting.
			_leftPage.y -= 1;
			_rightPage.y -= 1;

			_leftPageBackSheetIndex = -1;

			visible = false;
		}

		private function onPageMouseUp( event:MouseEvent3D ):void {
			if( _positionManager.onMotion ) return;
			var page:Page = event.target as Page;
			var clickUV:Point = event.uv;
			var pageClickX:Number = _pageWidth * clickUV.x;
			var pageClickY:Number = _pageHeight * clickUV.y;
			var sheetIndex:uint;
			if( page == _leftPage ) sheetIndex = _leftPage.backSheetIndex;
			else if( page == _rightPage ) sheetIndex = _rightPage.frontSheetIndex;
			else sheetIndex = page.flipAngle < 90 ? _middlePage.frontSheetIndex : _middlePage.backSheetIndex;
			_dataProvider.notifyClickAt( sheetIndex, pageClickX, pageClickY );
		}

		public function set dataProvider( value:BookDataProviderBase ):void {

			if( _dataProvider ) {
				_dataProvider.dispose();
			}

			_dataProvider = value;
			_dataProvider.textureReadySignal.add( onDataProviderTextureReady );

			// Produce snap points ( 1 for every pair of data provider items ).
			if( _dataProvider.numSheets % 2 != 0 ) {
				throw new Error( "Book - Book does not support data providers with an odd number of items." );
			}
			_numSnapPoints = _dataProvider.numSheets / 2;
			var xOffset:uint = 0;
			for( var i:uint = 0; i < _numSnapPoints; i++ ) {
				_positionManager.pushSnapPoint( xOffset );
				xOffset += SNAP_POINT_SPACING;
			}

			visible = true;

			update();
		}

		public function update():void {

//			trace( this, "update -------------------" );

			if( !_dataProvider ) return;

			// Update input and position.
			_interactionManager.update();
			_positionManager.update();

			// Evaluate snap point section index.
			var ratio:Number = _positionManager.position / SNAP_POINT_SPACING;
//			trace( "ratio: " + ratio );
			ratio = Math.round( ratio * 1000 ) / 1000; // stick to 3 decimals of accuracy. // TODO: review if needed
			var section:uint = Math.floor( ratio );
			// Edges.
			if( ratio < 0 ) ratio = section = 0;
			else if( ratio > _numSnapPoints - 1 ) ratio = section = _numSnapPoints - 1;
			var sectionOffset:Number = ratio - section;
			var leftSheetIndex:uint = 2 * section;
//			trace( "contained ratio: " + ratio );
//			trace( "section: " + section );
//			trace( "offset: " + sectionOffset );
//			trace( "leftSheetIndex: " + leftSheetIndex );

			// Need page swap?
			if( _leftPageBackSheetIndex != leftSheetIndex ) {
				_leftPageBackSheetIndex = leftSheetIndex;
				updatePageContent();
			}

			// Calculate active page rotation.
			_middlePage.flipAngle = sectionOffset * 180;
		}

		public function updatePageContent():void {

//			trace( this, "updating page content ------------------------" );
//			trace( "left page back sheet index: " + _leftPageBackSheetIndex );

			// Set all textures to default until new textures are ready.
			_leftPage.frontTexture = _leftPage.backTexture = _dataProvider.defaultTexture;
			_middlePage.frontTexture = _middlePage.backTexture = _dataProvider.defaultTexture;
			_rightPage.frontTexture = _rightPage.backTexture = _dataProvider.defaultTexture;

			// Associates pages with sheets, and refreshes the data provider to create and dispose data.
			_dataProvider.prepareToDisposeInactiveSheets();
			assignSheetIndicesToPage( -1, _leftPageBackSheetIndex, _leftPage );
			assignSheetIndicesToPage( _leftPageBackSheetIndex + 1, _leftPageBackSheetIndex + 2, _middlePage );
			assignSheetIndicesToPage( _leftPageBackSheetIndex + 3, -1, _rightPage );
			_dataProvider.disposeInactiveSheets();
		}

		private function assignSheetIndicesToPage( frontIndex:int, backIndex:int, page:Page ):void {

			var texture:BitmapTexture;

//			trace( this, "assigning indices " + frontIndex + ", " + backIndex + ", to page " + page.name );

			if( frontIndex >= 0 ) {
				page.frontSheetIndex = frontIndex;
				texture = _dataProvider.getTextureForSheet( frontIndex );
				if( texture ) page.frontTexture = texture;
			}

			if( backIndex >= 0 ) {
				page.backSheetIndex = backIndex;
				texture = _dataProvider.getTextureForSheet( backIndex );
				if( texture ) page.backTexture = texture;
			}
		}

		private function onDataProviderTextureReady( sheetIndex:uint, texture:BitmapTexture ):void {
//			trace( this, "texture ready: " + sheetIndex );
			if( _leftPage.backSheetIndex == sheetIndex ) {
				_leftPage.backTexture = texture;
//				trace( "set to left back" );
			}
			else if( _middlePage.frontSheetIndex == sheetIndex ) {
				_middlePage.frontTexture = texture;
//				trace( "set to middle front" );
			}
			else if( _middlePage.backSheetIndex == sheetIndex ) {
				_middlePage.backTexture = texture;
//				trace( "set to middle back" );
			}
			else if( _rightPage.frontSheetIndex == sheetIndex ) {
				_rightPage.frontTexture = texture;
//				trace( "set to right front" );
			}
		}

		public function startInteraction():void {
			_interactionManager.startInteraction();
		}

		public function stopInteraction():void {
			_interactionManager.stopInteraction();
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function get pageWidth():uint {
			return _pageWidth;
		}

		public function get pageHeight():uint {
			return _pageHeight;
		}
	}
}
