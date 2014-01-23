package net.psykosoft.psykopaint2.paint.configuration
{
	public class ColorStylePresets
	{
		
		private static var _presetLabels:Vector.<String>;
		private static var _presetData:Object;	
	
		private static const presets:XML = <presets>

					<factors name="Magritte 1" blend_in="21.03" blend_out="75.96000000000001">
					  <bin>
						<dimension x="107.41763013728625" y="43.89880338194427" z="18.780485945954528"/>
						<invRotationMatrix m="0.620859682559967,-0.7787504196166992,0.0898943617939949,0,0.5767850279808044,0.3761356472969055,-0.7251489758491516,0,0.5308975577354431,0.5020654797554016,0.6826990246772766,0,0,0,0,1"/>
						<rotationMatrix m="0.620859682559967,0.5767850279808044,0.5308976173400879,0,-0.7787503600120544,0.37613561749458313,0.5020654797554016,0,0.0898943692445755,-0.7251489162445068,0.6826990842819214,0,0,0,0,1"/>
						<mean x="71" y="65" z="58"/>
					  </bin>
					  <bin>
						<dimension x="100.93819846366361" y="44.27743566489665" z="15.264194546870142"/>
						<invRotationMatrix m="0.5780813097953796,-0.7187531590461731,0.3862847089767456,0,0.5128095746040344,-0.048218559473752975,-0.857147216796875,0,0.6347033381462097,0.693591296672821,0.34070923924446106,0,0,0,0,1"/>
						<rotationMatrix m="0.5780813694000244,0.5128096342086792,0.6347033977508545,0,-0.7187530994415283,-0.0482184924185276,0.6935913562774658,0,0.386284738779068,-0.8571471571922302,0.34070926904678345,0,0,0,0,1"/>
						<mean x="175" y="179" z="161"/>
					  </bin>
					</factors>

				
				
					<factors name="Ryden 1" blend_in="49.95" blend_out="54.26">
					  <bin>
						<dimension x="86.79839899906348" y="27.40748286070895" z="20.718234015876806"/>
						<invRotationMatrix m="0.7277569770812988,-0.6842369437217712,0.04679294675588608,0,0.5163038969039917,0.5016764998435974,-0.6940827965736389,0,0.4514421820640564,0.5292829871177673,0.7183728218078613,0,0,0,0,1"/>
						<rotationMatrix m="0.727756917476654,0.5163039565086365,0.4514422118663788,0,-0.6842369437217712,0.5016764998435974,0.5292830467224121,0,0.04679296538233757,-0.6940829157829285,0.7183728218078613,0,0,0,0,1"/>
						<mean x="85" y="76" z="45"/>
					  </bin>
					  <bin>
						<dimension x="100.4680121123821" y="44.7493201972006" z="17.57663866639966"/>
						<invRotationMatrix m="0.4644801914691925,-0.8314232230186462,0.30494844913482666,0,0.574910581111908,0.021173754706978798,-0.8179422616958618,0,0.6735993027687073,0.5552360415458679,0.48782879114151,0,0,0,0,1"/>
						<rotationMatrix m="0.4644801914691925,0.574910581111908,0.6735993027687073,0,-0.8314232230186462,0.0211737472563982,0.5552360415458679,0,0.3049484193325043,-0.817942202091217,0.4878287613391876,0,0,0,0,1"/>
						<mean x="168" y="157" z="122"/>
					  </bin>
					</factors>

					<factors name="Ryden 2" blend_in="15.77" blend_out="24.41">
					  <bin>
						<dimension x="57.966433440017894" y="17.472020945753098" z="5.691862796252646"/>
						<invRotationMatrix m="0.681892991065979,-0.7308902740478516,0.028658747673034668,0,0.5558426380157471,0.4923158288002014,-0.669823944568634,0,0.47545865178108215,0.472678005695343,0.7419666647911072,0,0,0,0,1"/>
						<rotationMatrix m="0.681892991065979,0.5558425784111023,0.47545865178108215,0,-0.7308903336524963,0.4923158288002014,0.472678005695343,0,0.02865877002477646,-0.669823944568634,0.741966724395752,0,0,0,0,1"/>
						<mean x="90" y="87" z="81"/>
					  </bin>
					  <bin>
						<dimension x="92.27854150022534" y="10.49457449572835" z="5.389693177526021"/>
						<invRotationMatrix m="0.5877689123153687,-0.75078946352005,0.3014014661312103,0,0.5950899124145508,0.14883165061473846,-0.7897576093673706,0,0.5480836629867554,0.6435559391975403,0.5342658758163452,0,0,0,0,1"/>
						<rotationMatrix m="0.5877689719200134,0.5950899720191956,0.5480836629867554,0,-0.7507895231246948,0.14883169531822205,0.6435559988021851,0,0.3014015257358551,-0.7897576093673706,0.53426593542099,0,0,0,0,1"/>
						<mean x="161" y="160" z="145"/>
					  </bin>
					</factors>

					<factors name="Picasso 1" blend_in="57.84" blend_out="59.68">
					  <bin>
						<dimension x="98.53641699014757" y="67.26662319344277" z="22.122266417555416"/>
						<invRotationMatrix m="0.9540150761604309,-0.1517401486635208,0.2585154175758362,0,0.2987191677093506,0.40949395298957825,-0.862021803855896,0,0.02494281902909279,0.8996052742004395,0.4359910786151886,0,0,0,0,1"/>
						<rotationMatrix m="0.9540150165557861,0.2987191677093506,0.02494281344115734,0,-0.15174013376235962,0.40949392318725586,0.8996052145957947,0,0.2585153877735138,-0.8620217442512512,0.4359910488128662,0,0,0,0,1"/>
						<mean x="74" y="63" z="61"/>
					  </bin>
					  <bin>
						<dimension x="93.64080103325124" y="69.67375151417964" z="24.49903079306275"/>
						<invRotationMatrix m="0.46116453409194946,-0.7362372279167175,0.495259553194046,0,0.5548741221427917,-0.1962740272283554,-0.8084498643875122,0,0.6924175024032593,0.6476351022720337,0.31800439953804016,0,0,0,0,1"/>
						<rotationMatrix m="0.46116453409194946,0.5548741221427917,0.6924175024032593,0,-0.7362372875213623,-0.1962740123271942,0.6476351022720337,0,0.495259553194046,-0.8084498643875122,0.3180043697357178,0,0,0,0,1"/>
						<mean x="177" y="164" z="112"/>
					  </bin>
					</factors>

					<factors name="Picasso 2" blend_in="52.58" blend_out="27.13">
					  <bin>
						<dimension x="110.65365304452565" y="82.5707215620841" z="19.338572128229206"/>
						<invRotationMatrix m="0.9424022436141968,-0.14601771533489227,0.3009265959262848,0,0.31993064284324646,0.6559829711914063,-0.6836159229278564,0,-0.09758266806602478,0.7405168414115906,0.6649153232574463,0,0,0,0,1"/>
						<rotationMatrix m="0.9424022436141968,0.31993064284324646,-0.09758267551660538,0,-0.14601773023605347,0.6559829711914063,0.7405169010162354,0,0.3009266257286072,-0.6836159825325012,0.6649153828620911,0,0,0,0,1"/>
						<mean x="84" y="53" z="25"/>
					  </bin>
					  <bin>
						<dimension x="115.24543857010245" y="76.35617422736574" z="14.705781395639589"/>
						<invRotationMatrix m="0.05048281326889992,-0.9547370672225952,0.2931358218193054,0,0.5442525744438171,-0.21980063617229462,-0.8096152544021606,0,0.8374010920524597,0.2004115730524063,0.5085219740867615,0,0,0,0,1"/>
						<rotationMatrix m="0.05048280581831932,0.5442526340484619,0.8374011516571045,0,-0.9547370672225952,-0.21980063617229462,0.2004115879535675,0,0.2931358218193054,-0.8096151947975159,0.5085220336914063,0,0,0,0,1"/>
						<mean x="184" y="148" z="93"/>
					  </bin>
					</factors>

					<factors name="Anatomie" blend_in="13.14" blend_out="43.4">
					  <bin>
						<dimension x="74.36025609349085" y="15.881503692878644" z="9.624581273082256"/>
						<invRotationMatrix m="0.8403874039649963,-0.4272221624851227,0.3335118889808655,0,0.5296598672866821,0.5168825387954712,-0.6725271940231323,0,0.11493206769227982,0.7418313026428223,0.6606640219688416,0,0,0,0,1"/>
						<rotationMatrix m="0.8403874635696411,0.5296599268913269,0.11493204534053802,0,-0.42722219228744507,0.5168825387954712,0.7418312430381775,0,0.33351197838783264,-0.6725273132324219,0.6606640219688416,0,0,0,0,1"/>
						<mean x="66" y="44" z="10"/>
					  </bin>
					  <bin>
						<dimension x="142.1531067873983" y="38.860327974534094" z="12.886502059708874"/>
						<invRotationMatrix m="0.47094202041625977,-0.7139764428138733,0.5181227922439575,0,0.610835611820221,-0.15982894599437714,-0.7754576206207275,0,0.6364695429801941,0.6816834211349487,0.36085209250450134,0,0,0,0,1"/>
						<rotationMatrix m="0.4709419906139374,0.6108355522155762,0.6364694833755493,0,-0.7139763832092285,-0.15982896089553833,0.6816834807395935,0,0.5181227922439575,-0.7754576206207275,0.36085209250450134,0,0,0,0,1"/>
						<mean x="200" y="160" z="74"/>
					  </bin>
					</factors>
						<factors name="Revolution" blend_in="13.14" blend_out="43.4">
						  <bin>
							<dimension x="96.94407885719565" y="39.63497569341678" z="11.017341404513335"/>
							<invRotationMatrix m="0.754469096660614,-0.5998241305351257,0.2664346396923065,0,0.5387176871299744,0.33406248688697815,-0.773424506187439,0,0.37491288781166077,0.727057933807373,0.5751757025718689,0,0,0,0,1"/>
							<rotationMatrix m="0.7544690370559692,0.5387176871299744,0.37491288781166077,0,-0.5998241901397705,0.3340625464916229,0.7270579934120178,0,0.2664346396923065,-0.7734245657920837,0.5751757025718689,0,0,0,0,1"/>
							<mean x="78" y="60" z="45"/>
						  </bin>
						  <bin>
							<dimension x="102.84900295856431" y="28.288604045281616" z="6.621449180169422"/>
							<invRotationMatrix m="0.46553876996040344,-0.6658723950386047,0.5829987525939941,0,0.6101178526878357,-0.23572838306427002,-0.7564313411712646,0,0.6411161422729492,0.7078460454940796,0.296519935131073,0,0,0,0,1"/>
							<rotationMatrix m="0.46553876996040344,0.6101177930831909,0.6411160826683044,0,-0.6658723950386047,-0.23572838306427002,0.7078461050987244,0,0.5829988121986389,-0.7564313411712646,0.296519935131073,0,0,0,0,1"/>
							<mean x="179" y="157" z="120"/>
						  </bin>
						</factors>
						<factors name="Lady in a Boat" blend_in="28.92" blend_out="24.41">
						  <bin>
							<dimension x="75.47178140605223" y="24.41085173424582" z="7.604055755738522"/>
							<invRotationMatrix m="0.7705231308937073,-0.6138070821762085,0.17185747623443604,0,0.5445083379745483,0.49367812275886536,-0.6780800223350525,0,0.3313680589199066,0.6160541772842407,0.7146134972572327,0,0,0,0,1"/>
							<rotationMatrix m="0.7705231308937073,0.5445083379745483,0.33136802911758423,0,-0.6138070821762085,0.49367815256118774,0.6160541772842407,0,0.17185744643211365,-0.6780800223350525,0.7146134972572327,0,0,0,0,1"/>
							<mean x="70" y="55" z="40"/>
						  </bin>
						  <bin>
							<dimension x="149.7500057464351" y="52.176249114139715" z="9.671693885610551"/>
							<invRotationMatrix m="0.3901304304599762,-0.7646664381027222,0.512916624546051,0,0.5341621041297913,-0.26577767729759216,-0.8025166988372803,0,0.7499794363975525,0.5870668292045593,0.3047678768634796,0,0,0,0,1"/>
							<rotationMatrix m="0.3901304006576538,0.534162163734436,0.7499793767929077,0,-0.7646664977073669,-0.26577770709991455,0.5870667695999146,0,0.5129166841506958,-0.802516758441925,0.304767906665802,0,0,0,0,1"/>
							<mean x="187" y="165" z="134"/>
						  </bin>
						</factors>
						<factors name="Beheading" blend_in="13.14" blend_out="124.79">
						  <bin>
							<dimension x="86.43837995904491" y="45.29551254431333" z="16.7854969446864"/>
							<invRotationMatrix m="0.7281229496002197,-0.6146240234375,0.30343735218048096,0,0.5334116220474243,0.230060875415802,-0.8139680624008179,0,0.43047529458999634,0.7545258402824402,0.49536022543907166,0,0,0,0,1"/>
							<rotationMatrix m="0.7281229496002197,0.5334116220474243,0.43047526478767395,0,-0.6146240234375,0.2300608605146408,0.7545258402824402,0,0.30343732237815857,-0.8139680624008179,0.49536022543907166,0,0,0,0,1"/>
							<mean x="78" y="51" z="38"/>
						  </bin>
						  <bin>
							<dimension x="142.71820469263258" y="51.683666476776644" z="13.14623713164549"/>
							<invRotationMatrix m="0.540771484375,-0.6852192282676697,0.4878942370414734,0,0.6110071539878845,-0.07866443693637848,-0.7877069115638733,0,0.5781318545341492,0.7240763306617737,0.37613436579704285,0,0,0,0,1"/>
							<rotationMatrix m="0.5407715439796448,0.6110071539878845,0.5781318545341492,0,-0.6852191686630249,-0.07866444438695908,0.7240763306617737,0,0.4878942668437958,-0.7877068519592285,0.37613439559936523,0,0,0,0,1"/>
							<mean x="197" y="173" z="131"/>
						  </bin>
						</factors>

						<factors name="Turner 1" blend_in="23.66" blend_out="29.84">
						  <bin>
							<dimension x="92.99318008053069" y="37.79996858313077" z="10.469678568551084"/>
							<invRotationMatrix m="0.6722747087478638,-0.6524155139923096,0.3498580753803253,0,0.6260803937911987,0.24885933101177216,-0.7389806509017944,0,0.39505699276924133,0.7158372402191162,0.5757664442062378,0,0,0,0,1"/>
							<rotationMatrix m="0.6722747087478638,0.6260803937911987,0.3950570523738861,0,-0.6524156332015991,0.24885934591293335,0.7158373594284058,0,0.34985795617103577,-0.7389805316925049,0.5757664442062378,0,0,0,0,1"/>
							<mean x="103" y="75" z="47"/>
						  </bin>
						  <bin>
							<dimension x="96.74231278315263" y="40.140886305539325" z="6.657416756248399"/>
							<invRotationMatrix m="0.5300334095954895,-0.6933445334434509,0.4881986379623413,0,0.623069167137146,-0.07208553701639175,-0.7788379192352295,0,0.5751950740814209,0.716991662979126,0.39379388093948364,0,0,0,0,1"/>
							<rotationMatrix m="0.5300334692001343,0.623069167137146,0.5751950740814209,0,-0.6933445334434509,-0.07208552211523056,0.716991662979126,0,0.4881986677646637,-0.7788378596305847,0.39379388093948364,0,0,0,0,1"/>
							<mean x="191" y="168" z="117"/>
						  </bin>
						</factors>

						<factors  name="Turner 2" blend_in="23.66" blend_out="29.84">
						  <bin>
							<dimension x="86.21933541099679" y="23.993757280827683" z="6.187218659560037"/>
							<invRotationMatrix m="0.717975378036499,-0.6390302777290344,0.27595600485801697,0,0.5397751331329346,0.2608243525028229,-0.8003833293914795,0,0.4394931197166443,0.7236096858978271,0.5321981310844421,0,0,0,0,1"/>
							<rotationMatrix m="0.717975378036499,0.5397750735282898,0.4394930899143219,0,-0.6390302777290344,0.2608243525028229,0.7236096858978271,0,0.27595603466033936,-0.8003833293914795,0.5321980714797974,0,0,0,0,1"/>
							<mean x="78" y="62" z="59"/>
						  </bin>
						  <bin>
							<dimension x="99.96578130746477" y="42.30612805219262" z="6.881081216911798"/>
							<invRotationMatrix m="0.5291129946708679,-0.7110140919685364,0.46313974261283875,0,0.6063166856765747,-0.06505495309829712,-0.7925578355789185,0,0.5936493277549744,0.7001619935035706,0.39667829871177673,0,0,0,0,1"/>
							<rotationMatrix m="0.5291130542755127,0.6063167452812195,0.5936493873596191,0,-0.7110139727592468,-0.06505484133958817,0.7001621127128601,0,0.46313977241516113,-0.7925578355789185,0.3966783285140991,0,0,0,0,1"/>
							<mean x="165" y="145" z="128"/>
						  </bin>
						</factors>
						
						<factors name="Turner 3" blend_in="68.35000000000001" blend_out="105.8">
						  <bin>
							<dimension x="83.36323612865763" y="49.47235168804194" z="16.29122550752796"/>
							<invRotationMatrix m="0.6983949542045593,-0.6538079977035522,0.2911692261695862,0,0.6289762854576111,0.3665473163127899,-0.6855887174606323,0,0.3415161073207855,0.6619502305984497,0.6672245860099792,0,0,0,0,1"/>
							<rotationMatrix m="0.6983950138092041,0.6289763450622559,0.34151607751846313,0,-0.6538081169128418,0.3665473163127899,0.6619502902030945,0,0.2911691963672638,-0.6855886578559875,0.6672245264053345,0,0,0,0,1"/>
							<mean x="118" y="85" z="40"/>
						  </bin>
						  <bin>
							<dimension x="98.21415256461144" y="46.726029138598555" z="10.401253790719743"/>
							<invRotationMatrix m="0.3440687954425812,-0.8360835909843445,0.42729485034942627,0,0.5935268402099609,-0.15896061062812805,-0.7889596819877625,0,0.7275593280792236,0.5250673890113831,0.44154468178749084,0,0,0,0,1"/>
							<rotationMatrix m="0.3440687656402588,0.5935268402099609,0.7275592684745789,0,-0.8360835909843445,-0.15896067023277283,0.5250673294067383,0,0.42729488015174866,-0.7889597415924072,0.44154468178749084,0,0,0,0,1"/>
							<mean x="192" y="176" z="111"/>
						  </bin>
						</factors>

					<factors name="Turner 4" blend_in="52.58" blend_out="54.26">
					  <bin>
						<dimension x="74.94238592581081" y="29.652749266147694" z="10.006831083648015"/>
						<invRotationMatrix m="0.6788398027420044,-0.5652692317962646,0.46866533160209656,0,0.6671093702316284,0.20807622373104095,-0.7153106927871704,0,0.30682501196861267,0.7982324361801147,0.5183468461036682,0,0,0,0,1"/>
						<rotationMatrix m="0.6788398027420044,0.6671093702316284,0.30682501196861267,0,-0.5652692317962646,0.20807622373104095,0.79823237657547,0,0.46866536140441895,-0.7153106927871704,0.5183467864990234,0,0,0,0,1"/>
						<mean x="75" y="70" z="38"/>
					  </bin>
					  <bin>
						<dimension x="106.85872072048247" y="51.25544539074301" z="6.286126944461186"/>
						<invRotationMatrix m="0.5294244885444641,-0.6089107394218445,0.5907092690467834,0,0.5841667056083679,-0.2432638555765152,-0.7743203043937683,0,0.6151901483535767,0.7550168037414551,0.22691555321216583,0,0,0,0,1"/>
						<rotationMatrix m="0.5294244885444641,0.5841667056083679,0.6151901483535767,0,-0.6089107990264893,-0.24326390027999878,0.7550168037414551,0,0.5907092094421387,-0.7743203043937683,0.22691553831100464,0,0,0,0,1"/>
						<mean x="204" y="195" z="119"/>
					  </bin>
					</factors>

					<factors name="Cezanne 1" blend_in="21.03" blend_out="141.06">
					  <bin>
						<dimension x="99.34766037876558" y="67.636581623088" z="15.079990700489997"/>
						<invRotationMatrix m="0.9048851132392883,0.044466160237789154,0.4233269691467285,0,0.3426465392112732,0.5139550566673279,-0.7864118218421936,0,-0.2525397539138794,0.8566638827323914,0.44983407855033875,0,0,0,0,1"/>
						<rotationMatrix m="0.9048851132392883,0.3426465094089508,-0.2525397539138794,0,0.04446618631482124,0.5139549970626831,0.8566638827323914,0,0.4233269691467285,-0.7864118218421936,0.44983410835266113,0,0,0,0,1"/>
						<mean x="94" y="73" z="33"/>
					  </bin>
					  <bin>
						<dimension x="133.28717836675082" y="69.95639145993054" z="11.288134485219096"/>
						<invRotationMatrix m="-0.12304258346557617,-0.9090295433998108,0.3981529474258423,0,0.3805966377258301,-0.4137480556964874,-0.8270179629325867,0,0.9165188074111938,0.049777235835790634,0.39688220620155334,0,0,0,0,1"/>
						<rotationMatrix m="-0.12304257601499557,0.3805966079235077,0.9165188074111938,0,-0.9090296030044556,-0.4137481153011322,0.049777258187532425,0,0.3981529772281647,-0.8270180225372314,0.39688223600387573,0,0,0,0,1"/>
						<mean x="159" y="179" z="166"/>
					  </bin>
					</factors>

					<factors  name="Cezanne 2" blend_in="2.63" blend_out="160.05">
					  <bin>
						<dimension x="84.0490971729077" y="52.1343113136378" z="19.32963513882555"/>
						<invRotationMatrix m="0.7171851992607117,-0.5863029360771179,0.37668853998184204,0,0.6139815449714661,0.27591052651405334,-0.7395269274711609,0,0.3296544551849365,0.7616575956344604,0.5578581094741821,0,0,0,0,1"/>
						<rotationMatrix m="0.7171852588653564,0.6139815449714661,0.32965442538261414,0,-0.5863029360771179,0.27591052651405334,0.7616575360298157,0,0.3766885995864868,-0.7395269274711609,0.5578581094741821,0,0,0,0,1"/>
						<mean x="60" y="58" z="35"/>
					  </bin>
					  <bin>
						<dimension x="95.41820048778744" y="85.29020788746683" z="14.977030689775733"/>
						<invRotationMatrix m="-0.3943004608154297,-0.8307191729545593,0.3929794132709503,0,0.3068687915802002,-0.5220996141433716,-0.7957659959793091,0,0.8662324547767639,-0.19317777454853058,0.4607859253883362,0,0,0,0,1"/>
						<rotationMatrix m="-0.3943004608154297,0.3068688213825226,0.8662324547767639,0,-0.8307191729545593,-0.5220996141433716,-0.19317775964736938,0,0.39297938346862793,-0.7957659959793091,0.46078595519065857,0,0,0,0,1"/>
						<mean x="140" y="149" z="108"/>
					  </bin>
					</factors>

					<factors name="Starry Night" blend_in="120.93" blend_out="103.09">
					  <bin>
						<dimension x="127.64661562436318" y="38.553613072847014" z="10.728529906044002"/>
						<invRotationMatrix m="0.19628512859344482,-0.7959594130516052,0.5726436972618103,0,0.5632907748222351,-0.386491984128952,-0.7302927374839783,0,0.8026055693626404,0.46591049432754517,0.3724939525127411,0,0,0,0,1"/>
						<rotationMatrix m="0.19628509879112244,0.5632907152175903,0.8026055097579956,0,-0.7959594130516052,-0.3864920139312744,0.4659104347229004,0,0.5726436972618103,-0.7302927374839783,0.3724939227104187,0,0,0,0,1"/>
						<mean x="48" y="80" z="110"/>
					  </bin>
					  <bin>
						<dimension x="124.46224908682537" y="63.942796232075665" z="11.424361118273161"/>
						<invRotationMatrix m="0.8393195271492004,0.22274290025234222,0.4959116280078888,0,0.35946938395500183,0.45693376660346985,-0.813629686832428,0,-0.40782901644706726,0.8611603379249573,0.30344417691230774,0,0,0,0,1"/>
						<rotationMatrix m="0.8393195867538452,0.35946938395500183,-0.40782901644706726,0,0.22274290025234222,0.4569338262081146,0.861160397529602,0,0.4959116280078888,-0.813629686832428,0.30344417691230774,0,0,0,0,1"/>
						<mean x="158" y="186" z="157"/>
					  </bin>
					</factors>

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
					<factors name="Grey 1"  blend_in="78.87" blend_out="0">
				  <bin>
					<dimension x="84.5067760746336" y="0.7003524054812954" z="0.47058138192227206"/>
					<invRotationMatrix m="0.5774656534194946,-0.5397397875785828,-0.6125473976135254,0,0.5768997073173523,0.8006625771522522,-0.16163592040538788,0,0.5776851177215576,-0.26003924012184143,0.7737308740615845,0,0,0,0,1"/>
					<rotationMatrix m="0.5774657130241394,0.5768997669219971,0.5776851773262024,0,-0.5397398471832275,0.8006625771522522,-0.26003924012184143,0,-0.6125473976135254,-0.1616358458995819,0.773730993270874,0,0,0,0,1"/>
					<mean x="36" y="36" z="36"/>
				  </bin>
				  <bin>
					<dimension x="168.1285224275112" y="0.584428705551057" z="0.42346152428555534"/>
					<invRotationMatrix m="0.5773202776908875,-0.6095244884490967,-0.5433058142662048,0,0.5773487687110901,0.7752476334571838,-0.2562411427497864,0,0.5773817896842957,-0.16574372351169586,0.7994743585586548,0,0,0,0,1"/>
					<rotationMatrix m="0.5773202180862427,0.5773487091064453,0.5773817896842957,0,-0.6095244884490967,0.7752476334571838,-0.16574370861053467,0,-0.5433058142662048,-0.256241112947464,0.7994743585586548,0,0,0,0,1"/>
					<mean x="168" y="168" z="168"/>
				  </bin>
				</factors>

				<factors name="Grey 2" blend_in="49.95" blend_out="48.83">
				  <bin>
					<dimension x="174.99714283381886" y="0" z="0"/>
					<invRotationMatrix m="0.5773502588272095,-0.5773502588272095,0.40824830532073975,0,0.5773502588272095,-0.5773502588272095,-0.8164966106414795,0,0.5773502588272095,-0.5773502588272095,0.40824830532073975,0,0,0,0,1"/>
					<rotationMatrix m="0.5773502588272095,-0.5773502588272095,0.40824830532073975,0,0.5773502588272095,-0.5773502588272095,-0.8164966106414795,0,0.5773502588272095,-0.5773502588272095,0.40824830532073975,0,0,0,0,1"/>
					<mean x="88" y="88" z="88"/>
				  </bin>
				  <bin>
					<dimension x="80.01249902359007" y="0" z="0"/>
					<invRotationMatrix m="0.5773502588272095,-0.5773502588272095,0.40824830532073975,0,0.5773502588272095,-0.5773502588272095,-0.8164966106414795,0,0.5773502588272095,-0.5773502588272095,0.40824830532073975,0,0,0,0,1"/>
					<rotationMatrix m="0.5773502588272095,-0.5773502588272095,0.40824830532073975,0,0.5773502588272095,-0.5773502588272095,-0.8164966106414795,0,0.5773502588272095,-0.5773502588272095,0.40824830532073975,0,0,0,0,1"/>
					<mean x="216" y="216" z="216"/>
				  </bin>
				</factors>

				<factors name="Black and White" blend_in="13.14" blend_out="0">
				  <bin>
					<dimension x="0" y="0" z="0"/>
					<invRotationMatrix m="0.5773502588272095,0.40824830532073975,-0.7071067690849304,0,-0.5773502588272095,0.8164966106414795,4.750590902120644e-18,0,0.5773502588272095,0.40824830532073975,0.7071067690849304,0,0,0,0,1"/>
					<rotationMatrix m="0.5773502588272095,-0.5773502588272095,0.5773502588272095,0,0.40824827551841736,0.8164965510368347,0.40824827551841736,0,-0.7071067690849304,4.6677914866677384e-8,0.7071067690849304,0,0,0,0,1"/>
					<mean x="0" y="0" z="0"/>
				  </bin>
				  <bin>
					<dimension x="282.75241002179683" y="0" z="0"/>
					<invRotationMatrix m="0.5773502588272095,0.8164966106414795,-4.750590902120644e-18,0,0.5773502588272095,-0.40824830532073975,-0.7071067690849304,0,0.5773502588272095,-0.40824830532073975,0.7071067690849304,0,0,0,0,1"/>
					<rotationMatrix m="0.5773502588272095,0.5773502588272095,0.5773502588272095,0,0.8164964914321899,-0.40824830532073975,-0.40824827551841736,0,-1.316128095396607e-8,-0.7071067690849304,0.7071067690849304,0,0,0,0,1"/>
					<mean x="136" y="136" z="136"/>
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
		
		
		private static function initPresets():void
		{
			_presetLabels = new Vector.<String>();
			_presetData = {};
			for ( var i:int = 0; i < presets.factors.length(); i++ )
			{
				_presetLabels.push( presets.factors[i].@name.toString() );
				_presetData[_presetLabels[i]] = presets.factors[i];
			}
		}
		
		public static function getPreset( styleName:String ):XML
		{
			if ( !_presetData ) initPresets();
			return _presetData[styleName] as XML;
		}
		
		public static function getAvailableColorStylePresets():Vector.<String> {
			if ( !_presetData ) initPresets();
			return _presetLabels;
		}
	}
}