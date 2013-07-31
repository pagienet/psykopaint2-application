package net.psykosoft.psykopaint2.core.drawing.modules
{
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.BitmapData;
	
	import net.psykosoft.psykopaint2.core.drawing.colortransfer.ColorTransfer;
	import net.psykosoft.psykopaint2.core.drawing.data.ModuleType;
	import net.psykosoft.psykopaint2.core.models.NavigationStateType;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleCompleteSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStyleModuleActivatedSignal;
	import net.psykosoft.psykopaint2.core.signals.NotifyColorStylePresetsAvailableSignal;
	import net.psykosoft.psykopaint2.core.signals.RequestColorStyleMatrixChangedSignal;

	public class ColorStyleModule implements IModule
	{
		[Inject]
		public var notifyColorStyleModuleActivatedSignal : NotifyColorStyleModuleActivatedSignal;

		[Inject]
		public var notifyColorStyleCompleteSignal : NotifyColorStyleCompleteSignal;
		
		[Inject]
		public var notifyColorStylePresetsAvailableSignal : NotifyColorStylePresetsAvailableSignal;
		
		[Inject]
		public var requestColorStyleMatrixChangedSignal : RequestColorStyleMatrixChangedSignal;
		
		private var _active : Boolean;
		private var _sourceMap : BitmapData;
		//private var _resultMap : BitmapData;
		private var _colorTransfer:ColorTransfer;
		private var _presetLabels:Array;
		private var _presetData:Object;
		private var _maxAnalysePixelCount:int = 256 * 256;
		private var _blendRange:int = 32;
		private var _blendIn:int = 0;
		private var _blendOut:int = 0;
		private const presets:XML = <presets>
				<factors name="mona lisa" blend_in="16" blend_out="16">
						<bin>
							<dimension x="72.77186883185043" y="27.268063805590984" z="14.93484412417759"/>
							<invRotationMatrix m="0.8371075987815857,-0.502905547618866,0.21526002883911133,0,0.5284088850021362,0.6415481567382813,-0.5560575127601624,0,0.14154475927352905,0.5792253017425537,0.8027846217155457,0,0,0,0,1"/>
							<rotationMatrix m="0.8371075987815857,0.528408944606781,0.14154474437236786,0,-0.5029056072235107,0.641548216342926,0.5792253017425537,0,0.2152600735425949,-0.5560576319694519,0.8027846217155457,0,0,0,0,1"/>
							<mean x="68" y="41" z="18"/>
						  </bin>
						  <bin>
							<dimension x="100.09562073772462" y="42.34460689814916" z="15.482048611859415"/>
							<invRotationMatrix m="0.7860435247421265,-0.5429052114486694,0.2956172227859497,0,0.5880066156387329,0.5090928077697754,-0.6285480856895447,0,0.19074544310569763,0.6678910255432129,0.719400942325592,0,0,0,0,1"/>
							<rotationMatrix m="0.7860434651374817,0.5880066156387329,0.19074545800685883,0,-0.5429052114486694,0.5090928673744202,0.6678910255432129,0,0.2956171929836273,-0.6285480856895447,0.719400942325592,0,0,0,0,1"/>
							<mean x="173" y="133" z="46"/>
						  </bin>
				</factors>
				<factors name="J.H. Lynch" blend_in="16" blend_out="16">
				  <bin>
					<dimension x="109.22273206674407" y="51.32993096295029" z="20.7213320117188"/>
					<invRotationMatrix m="0.8515851497650146,-0.47322186827659607,0.22553010284900665,0,0.46202388405799866,0.47428587079048157,-0.7493909597396851,0,0.24766245484352112,0.7423704862594604,0.6225346326828003,0,0,0,0,1"/>
					<rotationMatrix m="0.8515850305557251,0.46202391386032104,0.24766245484352112,0,-0.47322186827659607,0.47428593039512634,0.7423705458641052,0,0.22553007304668427,-0.7493909597396851,0.6225346326828003,0,0,0,0,1"/>
					<mean x="106" y="62" z="56"/>
				  </bin>
				  <bin>
					<dimension x="100.0033752967374" y="59.20445144840454" z="21.586803469114376"/>
					<invRotationMatrix m="0.3324507772922516,-0.7578495740890503,0.561373770236969,0,0.6282526850700378,-0.26598218083381653,-0.7311306595802307,0,0.7034024596214294,0.59574955701828,0.3876950442790985,0,0,0,0,1"/>
					<rotationMatrix m="0.332450807094574,0.6282526850700378,0.7034024596214294,0,-0.7578495144844055,-0.2659822404384613,0.5957494974136353,0,0.561373770236969,-0.7311306595802307,0.3876950442790985,0,0,0,0,1"/>
					<mean x="205" y="162" z="111"/>
				  </bin>
				</factors>
				<factors name="Franz Marc" blend_in="26.29" blend_out="32.55">
				  <bin>
					<dimension x="89.7472998229474" y="70.58212383737788" z="30.38189262918435"/>
					<invRotationMatrix m="0.8908534049987793,-0.3491087853908539,0.2906944751739502,0,0.43460750579833984,0.4686182737350464,-0.7690989375114441,0,0.13227444887161255,0.8114924430847168,0.5691955089569092,0,0,0,0,1"/>
					<rotationMatrix m="0.8908534049987793,0.43460753560066223,0.13227444887161255,0,-0.34910881519317627,0.46861836314201355,0.811492383480072,0,0.2906944751739502,-0.7690989971160889,0.5691955089569092,0,0,0,0,1"/>
					<mean x="106" y="84" z="77"/>
				  </bin>
				  <bin>
					<dimension x="77.64095953386361" y="55.09794940815214" z="26.15552855486001"/>
					<invRotationMatrix m="0.7053922414779663,0.5908318758010864,0.39158591628074646,0,0.052644260227680206,0.5072546005249023,-0.8601868152618408,0,-0.7068595290184021,0.627383828163147,0.3267095685005188,0,0,0,0,1"/>
					<rotationMatrix m="0.7053921818733215,0.05264419689774513,-0.7068595886230469,0,0.5908318758010864,0.5072546601295471,0.6273838877677917,0,0.39158594608306885,-0.8601868152618408,0.3267095983028412,0,0,0,0,1"/>
					<mean x="172" y="157" z="105"/>
				  </bin>
				</factors>
				<factors name="Goya"  blend_in="13.14" blend_out="10.85">
				  <bin>
					<dimension x="105.39276949346674" y="38.44542279699108" z="11.211648960086094"/>
					<invRotationMatrix m="0.7368874549865723,-0.613509476184845,0.2839067876338959,0,0.5479182600975037,0.2960454523563385,-0.7823954820632935,0,0.39595770835876465,0.7320951223373413,0.5543051958084106,0,0,0,0,1"/>
					<rotationMatrix m="0.7368873953819275,0.5479182600975037,0.39595773816108704,0,-0.613509476184845,0.2960454821586609,0.7320951223373413,0,0.2839067280292511,-0.7823954224586487,0.5543052554130554,0,0,0,0,1"/>
					<mean x="77" y="59" z="45"/>
				  </bin>
				  <bin>
					<dimension x="103.93424475186845" y="29.00553588444186" z="8.102319488810757"/>
					<invRotationMatrix m="0.4454672932624817,-0.6685146689414978,0.5955224633216858,0,0.5960388779640198,-0.2748895287513733,-0.7544358372688293,0,0.6680543422698975,0.6910310387611389,0.27600643038749695,0,0,0,0,1"/>
					<rotationMatrix m="0.44546735286712646,0.5960387587547302,0.6680542826652527,0,-0.6685146689414978,-0.2748894989490509,0.6910310387611389,0,0.5955224633216858,-0.7544357776641846,0.27600643038749695,0,0,0,0,1"/>
					<mean x="185" y="164" z="127"/>
				  </bin>
				</factors>
				<factors name="Caspar David Friedrich" blend_in="36.800000000000004" blend_out="0">
				  <bin>
					<dimension x="147.56962537155852" y="25.219301067181057" z="10.753763505465777"/>
					<invRotationMatrix m="0.5090939402580261,-0.7123106718063354,0.48315301537513733,0,0.6427603960037231,-0.05870192497968674,-0.7638148665428162,0,0.5724354982376099,0.6994051933288574,0.4279603064060211,0,0,0,0,1"/>
					<rotationMatrix m="0.5090939998626709,0.6427604556083679,0.5724354982376099,0,-0.7123106718063354,-0.05870192497968674,0.6994051337242126,0,0.4831530451774597,-0.7638148069381714,0.4279603362083435,0,0,0,0,1"/>
					<mean x="70" y="72" z="65"/>
				  </bin>
				  <bin>
					<dimension x="60.77166002271472" y="25.977230352561705" z="7.285404148939098"/>
					<invRotationMatrix m="0.7555794715881348,-0.4924873411655426,0.43192118406295776,0,0.48768654465675354,-0.017290586605668068,-0.8728475570678711,0,0.4373345375061035,0.8701478242874146,0.22711503505706787,0,0,0,0,1"/>
					<rotationMatrix m="0.7555795311927795,0.48768654465675354,0.4373345375061035,0,-0.4924873411655426,-0.017290586605668068,0.8701478242874146,0,0.4319211542606354,-0.8728475570678711,0.22711504995822906,0,0,0,0,1"/>
					<mean x="171" y="176" z="166"/>
				  </bin>
				</factors>
				<factors name="Munch" blend_in="21.03" blend_out="46.12">
				  <bin>
					<dimension x="130.1839461746753" y="63.3658220869107" z="11.895361252802626"/>
					<invRotationMatrix m="0.9603435397148132,-0.17173661291599274,0.21965165436267853,0,0.278781920671463,0.6043688058853149,-0.7463369965553284,0,-0.004577226005494595,0.7779748439788818,0.6282787322998047,0,0,0,0,1"/>
					<rotationMatrix m="0.9603434801101685,0.2787819504737854,-0.004577213432639837,0,-0.17173658311367035,0.6043688058853149,0.7779748439788818,0,0.21965166926383972,-0.7463371157646179,0.6282787322998047,0,0,0,0,1"/>
					<mean x="109" y="79" z="50"/>
				  </bin>
				  <bin>
					<dimension x="77.76868693886199" y="57.12761066646099" z="15.78605561517325"/>
					<invRotationMatrix m="0.01889987848699093,-0.9638259410858154,0.26586151123046875,0,0.5540510416030884,-0.21125081181526184,-0.8052331805229187,0,0.8322681188583374,0.1625196635723114,0.5300161838531494,0,0,0,0,1"/>
					<rotationMatrix m="0.01889987848699093,0.5540510416030884,0.8322680592536926,0,-0.9638259410858154,-0.21125082671642303,0.1625196486711502,0,0.26586151123046875,-0.8052332401275635,0.5300161838531494,0,0,0,0,1"/>
					<mean x="196" y="149" z="91"/>
				  </bin>
				</factors>
				<factors name="Le Guitarriste"  blend_in="31.55" blend_out="48.83">
				  <bin>
					<dimension x="81.82719086027959" y="25.14313911091821" z="8.878333093441256"/>
					<invRotationMatrix m="0.772753894329071,-0.3865404427051544,0.503426194190979,0,0.5955098867416382,0.1671391874551773,-0.7857686877250671,0,0.21958912909030914,0.9070010781288147,0.3593461215496063,0,0,0,0,1"/>
					<rotationMatrix m="0.7727539539337158,0.5955098867416382,0.21958912909030914,0,-0.38654041290283203,0.1671391725540161,0.9070010781288147,0,0.5034261345863342,-0.7857686281204224,0.3593461215496063,0,0,0,0,1"/>
					<mean x="97" y="74" z="19"/>
				  </bin>
				  <bin>
					<dimension x="101.41060300983914" y="27.848688379113053" z="6.393440600309486"/>
					<invRotationMatrix m="0.42608314752578735,-0.766497790813446,0.4805561900138855,0,0.5373945236206055,-0.21287645399570465,-0.8160213232040405,0,0.7277776598930359,0.6059411764144897,0.321208655834198,0,0,0,0,1"/>
					<rotationMatrix m="0.42608314752578735,0.5373944640159607,0.7277776002883911,0,-0.7664978504180908,-0.21287646889686584,0.605941116809845,0,0.4805561602115631,-0.8160212635993958,0.3212086260318756,0,0,0,0,1"/>
					<mean x="185" y="151" z="83"/>
				  </bin>
				</factors>
				</presets>;

		private var _renderNeeded : Boolean = true;
		
		
		public function ColorStyleModule()
		{
			super();
		}

		public function type():String {
			return ModuleType.COLOR_STYLE;
		}
		
		private function initPresets():void
		{
			_presetLabels = ["Original"];
			_presetData = {};
			for ( var i:int = 0; i < presets.factors.length(); i++ )
			{
				_presetLabels.push( presets.factors[i].@name.toString() );
				_presetData[_presetLabels[i+1]] = presets.factors[i];
			}
			
			notifyColorStylePresetsAvailableSignal.dispatch(_presetLabels);
		}

		public function activate(bitmapData : BitmapData) : void
		{
			_sourceMap = bitmapData;//BitmapDataUtils.getLegalBitmapData(bitmapData);
		//	_resultMap = _sourceMap.clone();
			
			_colorTransfer = new ColorTransfer();
			_colorTransfer.setTarget(_sourceMap, _maxAnalysePixelCount );
			_active = true;
			notifyColorStyleModuleActivatedSignal.dispatch(bitmapData);
			
			if ( _presetData == null ) initPresets();

			_renderNeeded = true;
			if ( _colorTransfer.hasSource ) render();
			
		}
		
		public function render():void
		{
			if (_renderNeeded && _colorTransfer.hasSource) {
				_colorTransfer.calculateColorMatrices();
				requestColorStyleMatrixChangedSignal.dispatch(  _colorTransfer.getColorMatrix(0),  _colorTransfer.getColorMatrix(1), _colorTransfer.getThreshold(_blendIn,_blendOut), _blendRange);
				//_colorTransfer.applyMatrices(_resultMap, _blendRange * 0.5, _blendRange * 0.5);
				_renderNeeded = false;
			}
		}
		
		/*
		public function get resultMap():BitmapData
		{
			return _resultMap;
		}
		*/
		
		public function get sourceMap():BitmapData
		{
			return _sourceMap;
		}

		public function deactivate() : void
		{
			_colorTransfer.dispose();
			_colorTransfer = null;
			
			_presetData = null;
			
			_active = false;
			/*
			if ( _sourceMap ) {
				_sourceMap.dispose();
				//we cannot dispose _result here since it is used by the next module!
			}
			*/
		}

		public function confirmColorStyle() : void
		{
			notifyColorStyleCompleteSignal.dispatch(_sourceMap);
		}
		
		public function setColorStyle( styleName:String ):void
		{
			if ( _presetData[styleName] )
			{
				_colorTransfer.setFactors(0,_presetData[styleName] as XML );
				_blendIn = _presetData[styleName].@blend_in;
				_blendOut =  _presetData[styleName].@blend_out;
				_blendRange = _blendIn + _blendOut;
				_renderNeeded = true;
				render();
			} else {
				requestColorStyleMatrixChangedSignal.dispatch( new ColorMatrix(), new ColorMatrix(), 0, 255);
				
				//_resultMap.copyPixels( _sourceMap, _sourceMap.rect, _sourceMap.rect.topLeft );
			}
		}


		public function getAvailableColorStylePresets():Array {
			return _presetLabels;
		}

		public function get stateType() : String
		{
			return NavigationStateType.COLOR_STYLE;
		}
	}
}