package net.psykosoft.psykopaint2.core.drawing.modules
{

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Stage3D;
	import flash.events.Event;

	import net.psykosoft.psykopaint2.core.drawing.BrushType;
	import net.psykosoft.psykopaint2.core.drawing.brushes.shapes.BrushShapeLibrary;
	import net.psykosoft.psykopaint2.core.drawing.brushkits.BrushKit;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;
	import net.psykosoft.psykopaint2.core.drawing.paths.PathManager;
	import net.psykosoft.psykopaint2.core.model.CanvasHistoryModel;
	import net.psykosoft.psykopaint2.core.model.CanvasModel;
	import net.psykosoft.psykopaint2.core.rendering.CanvasRenderer;
	import net.psykosoft.psykopaint2.base.remote.PsykoSocket;
	import net.psykosoft.psykopaint2.core.signals.NotifyActivateBrushChangedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyAvailableBrushTypesSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyPaintModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.notifications.NotifyMemoryWarningSignal;

	public class PaintModule implements IModule
	{
		[Inject]
		public var renderer : CanvasRenderer;

		[Inject]
		public var canvasModel : CanvasModel;

		[Inject]
		public var canvasHistory : CanvasHistoryModel;

		[Inject]
		public var notifyPaintModuleActivatedSignal : NotifyPaintModuleActivatedSignal;

		[Inject]
		public var brushShapeLibrary : BrushShapeLibrary;

		[Inject]
		public var notifyAvailableBrushTypesSignal:NotifyAvailableBrushTypesSignal;

		[Inject]
		public var notifyActivateBrushChangedSignal:NotifyActivateBrushChangedSignal;

		[Inject]
		public var memoryWarningSignal : NotifyMemoryWarningSignal;

		[Inject]
		public var stage3D : Stage3D;

		private var _view : DisplayObject;

		//private var _activeBrush : AbstractBrush;
		private var _active : Boolean;

		//private var _availableBrushTypes:Vector.<String>;
		//private var _brushClassFromBrushType:Dictionary;
		//private var _activeBrushType : String = null;
		private var _availableBrushKits:Vector.<BrushKit>;
		private var _availableBrushKitNames:Vector.<String>;
		private var _activeBrushKit : BrushKit;
		private var _activeBrushKitName : String;
		
		private const brushKitData:XML = 
			<brushkits>
				<brush engine={BrushType.WATER_COLOR} name="Water Color">
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}/>
					<shapes>
						<shape type="wet" />
						<shape type="basic" />
					</shapes>
				</brush>
				<brush engine={BrushType.WATER_DAMAGE} name="Water Damage">
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}/>
					<shapes>
						<shape type="wet" />
					</shapes>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Spray Can">
					<parameter id="Bumpyness" path="brush" value="0.2" />
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<SizeDecorator>
							<parameter id="Mode" path="pathengine.pointdecorator_0" index="1" />
							<parameter id="Factor" path="pathengine.pointdecorator_0" value="1" />
							<parameter id="Mapping" path="pathengine.pointdecorator_0" value="2" />
						</SizeDecorator>
						<ColorDecorator>
							<parameter id="Pick Color"  path="pathengine.pointdecorator_1" value="1" />
						</ColorDecorator>
						<SplatterDecorator>
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_2" value="8" />
							<parameter id="Minimum Offset" path="pathengine.pointdecorator_2" value="1" />
							<parameter id="Offset Angle Range" path="pathengine.pointdecorator_2" value="30" />
							<parameter id="Size Factor" path="pathengine.pointdecorator_2" value="0.02" />
						</SplatterDecorator>
					</pathengine>
					<shapes>
						<shape type="splat" />
						<shape type="splat3" />
						<shape type="line" />
						<shape type="basic" />
						<shape type="noisy" />
					</shapes>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Gravity Spray">
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<SizeDecorator>
							<!-- Mapping drawing speed to size -->
							<parameter id="Mode"  path="pathengine.pointdecorator_0" index="1" />
							<parameter id="Factor"  path="pathengine.pointdecorator_0" value="1" />
							<parameter id="Mapping" path="pathengine.pointdecorator_0" value="2" />
						</SizeDecorator>
						<StationaryDecorator>
							<!-- if not moving for 150ms start splattering around current position -->
							<parameter id="Delay"  path="pathengine.pointdecorator_1" value="150"  />
							<parameter id="Size"  path="pathengine.pointdecorator_1" value1="0.1" value2="0.3"  />
							<parameter id="Maximum Offset"  path="pathengine.pointdecorator_1" value="30" />
						</StationaryDecorator>
						<ColorDecorator>
							<!-- pick color at current point -->
							<parameter id="Pick Color"  path="pathengine.pointdecorator_0" value="1" />
						</ColorDecorator>
						<SplatterDecorator>
							<!-- randomize position -->
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_1" value="8" />
							<parameter id="Minimum Offset" path="pathengine.pointdecorator_1" value="1" />
							<parameter id="Offset Angle Range" path="pathengine.pointdecorator_1" value="360" />
						</SplatterDecorator>
						<ConditionalDecorator>
							<!-- if speed < 0.1 add dripping particles -->
							<parameter id="Test Property"  path="pathengine.pointdecorator_2" index="0" />
							<parameter id="Threshold"  path="pathengine.pointdecorator_2" value="0.1" />
						</ConditionalDecorator>
						<SizeDecorator>
							<parameter id="Mode"  path="pathengine.pointdecorator_3" index="0" />
							<parameter id="Factor" path="pathengine.pointdecorator_3" value1="0.02" value2="0.15"/>
						</SizeDecorator>
						<ParticleDecorator>
							<parameter id="Use Accelerometer"  path="pathengine.pointdecorator_4" value={1} />
							<parameter id="Curl Angle"  path="pathengine.pointdecorator_4" value={0} />
							<parameter id="Lifespan"  path="pathengine.pointdecorator_4" value1={150} value2={500}/>
							<parameter id="Render Steps per Frame" path="pathengine.pointdecorator_4" value={10}/>
							<parameter id="Update Probability" path="pathengine.pointdecorator_4" value1={1} value2={1}/>
							<parameter id="Spawn Probability" path="pathengine.pointdecorator_4" value={0.3}/>
							<parameter id="Minimum Spawn Distance" path="pathengine.pointdecorator_4" value={0}/>
							<parameter id="Max Concurrent Particles" path="pathengine.pointdecorator_4" value={20}/>
						</ParticleDecorator>
						<EndConditionalDecorator/>
						<EndConditionalDecorator/>
					</pathengine>
					<shapes>
						<shape type="noisy" />
					</shapes>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Tree Brush">
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<ColorDecorator>
							<parameter id="Pick Color"  path="pathengine.pointdecorator_0" value="1" />
						</ColorDecorator>
						<ConditionalDecorator>
							<parameter id="Test Property"  path="pathengine.pointdecorator_1" index="0" />
							<parameter id="Threshold"  path="pathengine.pointdecorator_1" value="0.75" />
						</ConditionalDecorator>
						<EndConditionalDecorator/>
							<ParticleDecorator>
								<parameter id="Lifespan"  path="pathengine.pointdecorator_3" value1={50} value2={200}/>
								<parameter id="Render Steps per Frame" path="pathengine.pointdecorator_3" value={4}/>
								<parameter id="Update Probability" path="pathengine.pointdecorator_3" value1={1} value2={1}/>
								<parameter id="Spawn Probability" path="pathengine.pointdecorator_3" value={0.2}/>
								<parameter id="Minimum Spawn Distance" path="pathengine.pointdecorator_3" value={1}/>
								<parameter id="Max Concurrent Particles" path="pathengine.pointdecorator_3" value={20}/>
							</ParticleDecorator>
						<EndConditionalDecorator/>
						<SplatterDecorator>
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_5" value="3" />
							<parameter id="Minimum Offset" path="pathengine.pointdecorator_5" value="1" />
							<parameter id="Offset Angle Range" path="pathengine.pointdecorator_5" value="360" />
						</SplatterDecorator>
						<SizeDecorator>
								<parameter id="Mode"  path="pathengine.pointdecorator_6" index="1"/>
								<parameter id="Factor" path="pathengine.pointdecorator_6" value1="0.2" value2="0.2"/>
								<parameter id="Mapping" path="pathengine.pointdecorator_6" value="2" />
						</SizeDecorator>
					</pathengine>
					<shapes>
						<shape type="inkdots1" />
						<shape type="test" />
						<shape type="splat" />
						<shape type="line" />
						<shape type="noisy" />
					</shapes>
				</brush>
				<brush engine={BrushType.SHATTER} name="Shatter">
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<parameter id="Output Step Size" path="pathengine" value="3"/>
					</pathengine>
					<shapes>
						<shape type="splat" />
						<shape type="splat3" />
						<shape type="line" />
						<shape type="basic" />
					</shapes>
				</brush>
				<brush engine={BrushType.SPRAY_CAN} name="Circular">
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<ColorDecorator>
							<parameter id="Pick Color"  path="pathengine.pointdecorator_0" value="1" />
						</ColorDecorator>
						<CircularRotationDecorator>
							<parameter id="Angle Adjustment"  path="pathengine.pointdecorator_1" value={90} />
							<centers>
								<point x="0.5" y="0.5"/>
							</centers>
						</CircularRotationDecorator>
					</pathengine>
					<shapes>
						<shape type="splat" />
						<shape type="splat3" />
						<shape type="line" />
						<shape type="basic" />
					</shapes>
				</brush>
				<brush engine={BrushType.UNCOLORED_SPRAY_CAN} name="Ink dots">
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<SplatterDecorator>
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_0" value="8" />
							<parameter id="Minimum Offset"  path="pathengine.pointdecorator_0" value="3" />
							<parameter id="Offset Angle Range" path="pathengine.pointdecorator_0" value="30" />
							<parameter id="Size Factor" path="pathengine.pointdecorator_0" value="0.6" />
						</SplatterDecorator>
						<ColorDecorator>
							<parameter id="Pick Color"  path="pathengine.pointdecorator_1" value="1" />
						</ColorDecorator>
					</pathengine>
					<shapes>
						<shape type="inkdots1" />
						<shape type="objects" />
					</shapes>
				</brush>
				<brush engine={BrushType.UNCOLORED_SPRAY_CAN} name="Pointillist">
					<parameter id="Size Factor" path="brush" value1="0.05" value2="0.08"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<GridDecorator> 
							<parameter id="Cell Width"  path="pathengine.pointdecorator_0" value="8" />
							<parameter id="Cell Height"  path="pathengine.pointdecorator_0" value="8"/>
						</GridDecorator>
						<ColorDecorator>
							<parameter id="Pick Color"  path="pathengine.pointdecorator_1" value="1" />
						</ColorDecorator>
						<SpawnDecorator>
							<parameter id="Multiples" value1="2" path="pathengine.pointdecorator_2" value2="6"/>
							<parameter id="Maximum Offset" path="pathengine.pointdecorator_2" value="16"/>
							<parameter id="Offset Parent Point" path="pathengine.pointdecorator_2" value="1"/>
						</SpawnDecorator>
					</pathengine>
					<shapes>
						<shape type="inkdots1" />
					</shapes>
				</brush>
				<brush engine={BrushType.DELAUNAY} name="Delaunay">
					<parameter id="Size Factor" path="brush" value1="0.1" value2="0.2"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<parameter id="Output Step Size" path="pathengine" value="30"  />
						<SplatterDecorator>
							<parameter id="Splat Factor"  path="pathengine.pointdecorator_0" value="8" />
							<parameter id="Minimum Offset" path="pathengine.pointdecorator_0" value="1" />
						</SplatterDecorator>
					</pathengine>
					<shapes>
						<shape type="scales" />
					</shapes>
				</brush>
				
				<brush engine={BrushType.SPRAY_CAN} name="Precision Test">
					<parameter id="Bumpyness" path="brush" value="0" />
					<parameter id="Size Factor" path="brush" value1="1" value2="1"/>
					<pathengine type={PathManager.ENGINE_TYPE_BASIC}>
						<ColorDecorator>
							<parameter id="Pick Color"  path="pathengine.pointdecorator_0" value="1" />
						</ColorDecorator>
						<GridDecorator>
							<parameter id="Angle Step"  path="pathengine.pointdecorator_1" value={360} />
							<parameter id="Angle Offset" path="pathengine.pointdecorator_1" value={45} />
							<parameter id="Cell Width" path="pathengine.pointdecorator_1" value={64} />
							<parameter id="Cell Height" path="pathengine.pointdecorator_1" value={64} />
							<parameter id="Row Offset" path="pathengine.pointdecorator_1" value={32} />
						</GridDecorator>
					</pathengine>
					<shapes>
						<shape type="test" />
					</shapes>
				</brush>
			</brushkits>
		
		
		public function PaintModule()
		{
			super();
			
			for ( var i:int = 0; i < brushKitData.brush.length(); i++ )
			{
				registerBrushKit( BrushKit.fromXML(brushKitData.brush[i]), brushKitData.brush[i].@name);
			}
			/*
			registerBrush( BrushType.WATER_COLOR, WaterColorBrush );
			registerBrush( BrushType.WATER_DAMAGE, WaterDamageBrush );
			registerBrush( BrushType.SPRAY_CAN, SprayCanBrush );
			registerBrush( BrushType.INK_DOTS, UncoloredSprayCanBrush );
			registerBrush( BrushType.POINTILLIST, PointillistBrush );
			registerBrush( BrushType.DELAUNAY, DelaunayBrush );
			registerBrush( BrushType.SHATTER, ShatterBrush );
			*/
		}

		[PostConstruct]
		public function postConstruct() : void
		{
			BrushKit.brushShapeLibrary = brushShapeLibrary;
			
			memoryWarningSignal.add(onMemoryWarning);
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
			//notifyAvailableBrushTypesSignal.dispatch( _availableBrushTypes );
			//activeBrush = BrushType.SPRAY_CAN;
			notifyAvailableBrushTypesSignal.dispatch( _availableBrushKitNames );
		
		}

		/*
		private function registerBrush( brushName:String, brushClass:Class ):void {
			if( !_availableBrushTypes ) _availableBrushTypes = new Vector.<String>();
			if( !_brushClassFromBrushType ) _brushClassFromBrushType = new Dictionary();
			_availableBrushTypes.push( brushName );
			_brushClassFromBrushType[ brushName ] = brushClass;
		}
		*/
		
		private function registerBrushKit( brushKit:BrushKit, kitName:String ):void {
			if( !_availableBrushKits ) _availableBrushKits = new Vector.<BrushKit>();
			_availableBrushKits.push(brushKit);
			if( !_availableBrushKitNames ) _availableBrushKitNames = new Vector.<String>();
			_availableBrushKitNames.push(kitName);
		}
		
		public function get activeBrushKit() : String
		{
			return _activeBrushKitName;
		}

		public function get activeBrushKitShape():String {
			return _activeBrushKit.getActiveBrushShape;
		}

		public function set activeBrushKit( brushKitName:String ) : void
		{
			
			if (_activeBrushKitName == brushKitName) return;
			if ( _activeBrushKit ) deactivateBrushKit();
			
			_activeBrushKitName = brushKitName;
			_activeBrushKit = _availableBrushKits[ _availableBrushKitNames.indexOf(brushKitName)];
			if (_active) activateBrushKit();
			
			//trace( this, "activating brush kit: " + _activeBrushKitName + ", engine: " + _activeBrushKit.brushEngine + " --------------------" );
			
			var brushShapes:XML = _activeBrushKit.getShapeSet();
			
			//trace( this, "available shapes: " +brushShapes );
			
			if (!_activeBrushKit.brushEngine.brushShape && brushShapes != null && brushShapes.shape.length() > 0 ) {
				setBrushShape( brushShapes.shape[0].@type );
			}
			notifyActivateBrushChangedSignal.dispatch( _activeBrushKit.getParameterSet() );
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

		public function activate(bitmapData : BitmapData) : void
		{
			initializeDefaultBrushes();

			_active = true;
			if ( !_activeBrushKit ) activeBrushKit = _availableBrushKitNames[0];
			activateBrushKit();
			renderer.init(this);
			canvasModel.setSourceBitmapData(bitmapData);
			bitmapData.dispose();
			notifyPaintModuleActivatedSignal.dispatch();
		}

		public function deactivate() : void
		{
			_active = false;
			deactivateBrushKit();
		}

		private function onBrushComplete(event : Event) : void
		{
			canvasHistory.addSnapShot(_activeBrushKit.brushEngine.snapshot);
		}

		private function activateBrushKit() : void
		{
			if ( _activeBrushKit )
			{
				_activeBrushKit.activate(_view, stage3D.context3D, canvasModel, canvasHistory);
				_activeBrushKit.brushEngine.addEventListener(Event.COMPLETE, onBrushComplete);
				_activeBrushKit.addEventListener( Event.CHANGE, onActiveBrushKitChanged );
			}
		}

		private function deactivateBrushKit() : void
		{
			if ( _activeBrushKit )
			{
				_activeBrushKit.deactivate();
				_activeBrushKit.brushEngine.removeEventListener(Event.COMPLETE, onBrushComplete);
				_activeBrushKit.removeEventListener( Event.CHANGE, onActiveBrushKitChanged );
				_activeBrushKit = null;
				_activeBrushKitName = "";
			}
		}

		private function onActiveBrushKitChanged( event:Event ):void
		{
			notifyActivateBrushChangedSignal.dispatch( _activeBrushKit.getParameterSet() );
		}
		/*
		public function getAvailableBrushShapes() : Array
		{
			return _activeBrushKit.brushEngine.getAvailable BrushShapes();
		}
		*/

		public function getAvailableBrushTypes() : Vector.<String> {
			return _availableBrushKitNames;
		}

		public function getCurrentBrushShapes():XML {
			return _activeBrushKit.getShapeSet();
		}

		public function getCurrentBrushParameters():XML {
			return _activeBrushKit.getParameterSet();
		}

		public function setBrushShape(id : String) : void
		{
			_activeBrushKit.setBrushShape( id );
		}
		
		/*
		public function setColorBlending( minColorBlendFactor:Number, maxColorBlendFactor:Number, minimumOpacity:Number, maximumOpacity:Number ):void 
		{
			_activeBrushKit.brushEngine.setColorBlending( minColorBlendFactor, maxColorBlendFactor, minimumOpacity, maximumOpacity );
		}
		
		public function setBrushSizeFactors( minSizeFactor:Number,  maxSizeFactor:Number ):void 
		{
			_activeBrushKit.brushEngine.setBrushSizeFactors( minSizeFactor, maxSizeFactor );
		}
		*/

		public function setBrushParameter( parameter:XML ):void 
		{
			_activeBrushKit.setBrushParameter( parameter );
		}

		public function render() : void
		{
			if ( _activeBrushKit ) _activeBrushKit.brushEngine.draw();
			renderer.render();
		}

		private function onMemoryWarning() : void
		{
			PsykoSocket.sendString( '<msg src="PaintModule.onMemoryWarning" />' );
			if (_activeBrushKit)
				_activeBrushKit.brushEngine.freeExpendableMemory();
		}
	}
}