package net.psykosoft.psykopaint2.core.drawing.modules
{

	import com.greensock.TweenLite;
	import com.greensock.easing.Sine;

	import flash.display.DisplayObject;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.drawing.brushes.AbstractBrush;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.BrushShapeLibrary;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;
	import net.psykosoft.psykopaint2.core.drawing.data.ParameterSetVO;
	import net.psykosoft.psykopaint2.core.managers.gestures.GestureType;
	import net.psykosoft.psykopaint2.core.managers.pen.WacomPenManager;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.models.PaintModeModel;
	import net.psykosoft.psykopaint2.core.models.PaintModeType;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.core.signals.NotifyActivateBrushChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyAvailableBrushTypesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyCanvasMatrixChanged;
	import net.psykosoft.psykopaint2.core.signals.NotifyGlobalGestureSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyMemoryWarningSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationAutohideModeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationStateChangeSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestNavigationToggleSignal;
	import net.psykosoft.psykopaint2.paint.configuration.BrushKitDefaultSet;

	import org.gestouch.events.GestureEvent;

	// TODO: Clean up by moving into custom stuff where not affecting brush kits
	public class BrushKitManager
	{
		[Inject]
		public var renderer : CanvasRenderer;

		[Inject]
		public var canvasModel : CanvasModel;

		[Inject]
		public var canvasHistory : CanvasHistoryModel;

		[Inject]
		public var stage3D : Stage3D;
		
		[Inject]
		public var penManager : WacomPenManager;
		
		[Inject]
		public var brushShapeLibrary : BrushShapeLibrary;

		[Inject]
		public var notifyAvailableBrushTypesSignal:NotifyAvailableBrushTypesSignal;

		[Inject]
		public var notifyActivateBrushChangedSignal:NotifyActivateBrushChangedSignal;

		[Inject]
		public var memoryWarningSignal : NotifyMemoryWarningSignal;

		[Inject]
		public var requestStateChangeSignal:RequestNavigationStateChangeSignal;

		[Inject]
		public var notifyGlobalGestureSignal : NotifyGlobalGestureSignal;
		
		[Inject]
		public var requestNavigationToggleSignal:RequestNavigationToggleSignal;
		
		[Inject]
		public var requestNavigationAutohideModeSignal:RequestNavigationAutohideModeSignal;

		[Inject]
		public var notifyCanvasMatrixChanged : NotifyCanvasMatrixChanged;
		
		private var _view : DisplayObject;
		private var _active : Boolean;
		private var _availableBrushKits:Vector.<BrushKit>;
		private var _availableBrushKitNames:Vector.<String>;
		private var _activeBrushKit : BrushKit;
		private var _activeBrushKitName : String;
		private var _canvasMatrix : Matrix;
		//private var _navHideTimeout:int = -1;
		private var _navShowTimeout:int = -1;
		private var sourceCanvasViewModes:Array = [[1,0.25],[1,0],[1,1],[0.01,1]];
		private var sourceCanvasViewModeIndex:int = 0;
		private var _activeMode : int;
		
		public function BrushKitManager()
		{
			super();
		}

		[PostConstruct]
		public function postConstruct() : void
		{
			AbstractBrush.brushShapeLibrary = brushShapeLibrary;
			memoryWarningSignal.add(onMemoryWarning);
			notifyCanvasMatrixChanged.add(onCanvasMatrixChanged);
			notifyGlobalGestureSignal.add( onGlobalGesture );
		}

		// TODO: Handle gestures somewhere else
		private function onGlobalGesture( gestureType:String, event:GestureEvent):void
		{
			if ( gestureType == GestureType.TAP_GESTURE_RECOGNIZED && _activeMode == BrushKitMode.PHOTO )
			{
				sourceCanvasViewModeIndex = ( sourceCanvasViewModeIndex+1) % sourceCanvasViewModes.length;
				TweenLite.killTweensOf( renderer );
				TweenLite.to( renderer, 0.6, { paintAlpha:sourceCanvasViewModes[sourceCanvasViewModeIndex][0],sourceTextureAlpha: sourceCanvasViewModes[sourceCanvasViewModeIndex][1], ease: Sine.easeInOut } );
				
				
			} else if ( gestureType == GestureType.TRANSFORM_GESTURE_BEGAN )
			{
				_activeBrushKit.deactivate();
			}  else if ( gestureType == GestureType.TRANSFORM_GESTURE_ENDED )
			{
				_activeBrushKit.activate(_view, stage3D.context3D, canvasModel, renderer);
			}
		}

		private function onCanvasMatrixChanged(matrix : Matrix) : void
		{
			_canvasMatrix = matrix;
			if (_activeBrushKit)
				_activeBrushKit.setCanvasMatrix(matrix);
		}
		
		public function stopAnimations() : void
		{
			if (_activeBrushKit)
				_activeBrushKit.stopProgression();
		}

		public function type():String {
			return ModuleType.PAINT;
		}

		private function initializeDefaultBrushes():void {
			notifyAvailableBrushTypesSignal.dispatch( _availableBrushKitNames );
		}

		private function registerBrushKit( brushKit:BrushKit, kitName:String ):void {

			trace( this, "registerBrushKit: " + kitName );

			if( !_availableBrushKits ) 
			{
				_availableBrushKits = new Vector.<BrushKit>();
			}
			
			if( !_availableBrushKitNames ) 
			{
				_availableBrushKitNames = new Vector.<String>();
			}
			
			_availableBrushKits.push(brushKit);
			_availableBrushKitNames.push(kitName);
		}
		
		public function get activeBrushKit() : String
		{
			return _activeBrushKitName;
		}

		public function set activeBrushKit( brushKitName:String ) : void
		{
			if (_activeBrushKitName == brushKitName) return;
			if ( _activeBrushKit ) deactivateBrushKit();
			
			_activeBrushKitName = brushKitName;
			_activeBrushKit = _availableBrushKits[ _availableBrushKitNames.indexOf(brushKitName)];
			if (_active) activateBrushKit();
			
			//trace( this, "activating brush kit: " + _activeBrushKitName + ", engine: " + _activeBrushKit.brushEngine + " --------------------" );
			
			notifyActivateBrushChangedSignal.dispatch( _activeBrushKit.getParameterSet( !CoreSettings.SHOW_HIDDEN_BRUSH_PARAMETERS ) );
		}

		
		public function get view() : DisplayObject
		{
			return _view;
		}

		public function set view(view : DisplayObject) : void
		{
			if (_active)
				deactivateBrushKit();

			_view = view;

			if (_active)
				activateBrushKit();
		}

		public function activate(mode : int) : void
		{
			var brushKitDef : XML = mode == BrushKitMode.PHOTO? BrushKitDefaultSet.brushKitDataPhotoPaintMode : BrushKitDefaultSet.brushKitDataColorMode;

			for ( var i:int = 0; i < brushKitDef.brush.length(); i++ )
				registerBrushKit( BrushKit.fromXML(brushKitDef.brush[i]), brushKitDef.brush[i].@name);

			initializeDefaultBrushes();

			_activeMode = mode;
			_active = true;
			if ( !_activeBrushKit ) activeBrushKit = _availableBrushKitNames[0];
			activateBrushKit();
		}

		public function deactivate() : void
		{
			_active = false;
			deactivateBrushKit();
		}

		private function onStrokeStarted(event : Event) : void
		{
			_activeBrushKit.brushEngine.snapShot = canvasHistory.takeSnapshot();
			/*
			if ( _navShowTimeout != -1 )
			{
				clearTimeout( _navShowTimeout );
				_navShowTimeout = -1;
			}
			*/
			
			requestNavigationAutohideModeSignal.dispatch( true );
			//if ( _navHideTimeout == -1 ) _navHideTimeout = setTimeout( triggerToogleNavBar, 1000, false );
			
		}
		
		private function onStrokeEnded(event : Event) : void
		{
			/*
			if ( _navHideTimeout != -1 ) {
				clearTimeout( _navHideTimeout );
				_navHideTimeout = -1;
			}
			*/
			
			if ( _navShowTimeout != -1 ) {
				clearTimeout( _navShowTimeout );
				_navShowTimeout = -1;
			}
			_navShowTimeout = setTimeout( triggerToogleNavBar, 500, true );
			requestNavigationAutohideModeSignal.dispatch( false );
		}

		private function activateBrushKit() : void
		{
			if ( _activeBrushKit )
			{
				_activeBrushKit.setCanvasMatrix(_canvasMatrix);
				_activeBrushKit.activate( _view, stage3D.context3D, canvasModel, renderer);
				_activeBrushKit.brushEngine.addEventListener( AbstractBrush.STROKE_STARTED, onStrokeStarted);
				_activeBrushKit.brushEngine.addEventListener( AbstractBrush.STROKE_ENDED, onStrokeEnded );
				_activeBrushKit.addEventListener( Event.CHANGE, onActiveBrushKitChanged );
			}
		}

		private function deactivateBrushKit() : void
		{
			if ( _activeBrushKit )
			{
				_activeBrushKit.deactivate();
				_activeBrushKit.brushEngine.removeEventListener(AbstractBrush.STROKE_STARTED, onStrokeStarted);
				_activeBrushKit.brushEngine.removeEventListener( AbstractBrush.STROKE_ENDED, onStrokeEnded );
				_activeBrushKit.removeEventListener( Event.CHANGE, onActiveBrushKitChanged );
				_activeBrushKit = null;
				_activeBrushKitName = "";
			}
		}

		private function onActiveBrushKitChanged( event:Event ):void
		{
			notifyActivateBrushChangedSignal.dispatch( _activeBrushKit.getParameterSetAsXML() );
		}
		
		
		private function triggerToogleNavBar( show:Boolean ):void
		{
			//_navHideTimeout
			_navShowTimeout = -1;
			requestNavigationToggleSignal.dispatch(show ? 1 : -1, 0.1);
		}
		
		
		
		public function getAvailableBrushTypes() : Vector.<String> {
			return _availableBrushKitNames;
		}

		
		public function getCurrentBrushParameters( uiOnlyParameters:Boolean = true):ParameterSetVO {
			return _activeBrushKit.getParameterSet( uiOnlyParameters );
		}
		
		public function update() : void
		{
			if ( _activeBrushKit ) _activeBrushKit.brushEngine.draw();
		}

		private function onMemoryWarning() : void
		{
			if ( CoreSettings.ENABLE_PSYKOSOCKET_CONNECTION )
			{
				PsykoSocket.sendString( '<msg src="PaintModule.onMemoryWarning" />' );
			}
			if (_activeBrushKit)
				_activeBrushKit.brushEngine.freeExpendableMemory();
		}

		public function get activeMode() : int
		{
			return _activeMode;
		}
	}
}