import("stdfaust.lib");

switch= en.adsre(0.5,0.1,1,1,checkbox("switch"));
switch2= en.adsre(0.5,0.1,1,1,1-checkbox("switch"));

process = part_radio,part_dialog :> _,_;

part_radio = playerPad, playerVoice :> _*(switch),_*(switch);

part_dialog = Ququ , Birds :> _*(switch2),_*(switch2);


////////
selectPart(sec,offset) =no.pink_noise: de.delay(ma.SR*sec, offset) :abs:*(100):int:ba.sAndH(ba.pulse(ma.SR*sec))%3;
selectPart21(sec,offset) =no.pink_noise: de.delay(ma.SR*sec, offset) :abs:*(500):int:ba.sAndH(ba.pulse(ma.SR*sec))%21;
level = hslider("level", 0.5, 0, 1, 0.01);

s1 = soundfile("[url:{'RADIO1.wav';'RADIO2.wav';'RADIO3.wav'}]",1);
sample1 = so.sound(s1, 0);
sample2 = so.sound(s1, 1);
sample3 = so.sound(s1, 2);

s2 = soundfile("[url:{'dialog1.wav';
					  'dialog2.wav';
					  'dialog3.wav';
	                  'lenny.wav';
					  'rg3.wav';
					  'macron3.wav';
					  'macron4.wav';
					  'jiaomaidiao1.wav';
					  'jiaomaidiao2.wav';
					  'jiaomaidiao3.wav';
					  'nainai1.wav';
					  'nainai2.wav';
					  'xinwen1.wav';
					  'xinwen2.wav';
					  'journal1.wav';
					  'journal2.wav';
					  'journal3.wav';
					  'macron1.wav';
					  'macron2.wav';
					  'rg1.wav';
					  'rg2.wav'}]",1);

volume(sec,offset) = ba.pulse(ma.SR*sec):ba.peakholder(ma.SR*sec/2):ba.ramp(18000): de.delay(ma.SR*sec, offset);

pad1 = volume(20,0) * select3(selectPart(20,0),sample1.loop_speed_level(1,0.3),sample2.loop_speed_level(1, 0.4),sample3.loop_speed_level(1, 0.5));
pad2 = volume(10,ma.SR) * select3(selectPart(10,ma.SR),sample1.loop_speed_level(1,0.3),sample2.loop_speed_level(1, 0.4),sample3.loop_speed_level(1, 0.5));
pad3 = volume(12,ma.SR*5) * select3(selectPart(12,ma.SR*5),sample1.loop_speed_level(1,0.3),sample2.loop_speed_level(1, 0.4),sample3.loop_speed_level(1, 0.5));
pad4 = volume(16,ma.SR*3) * select3(selectPart(16,ma.SR*3),sample1.loop_speed_level(1,0.3),sample2.loop_speed_level(1, 0.4),sample3.loop_speed_level(1, 0.5));

playerPad = pad1 , pad2 , pad3 , pad4 :> _,_ ;

voice1 = volume(4,0) * ba.selectmulti(ma.SR/10, par(i, 18, so.sound(s2, i).loop_speed_level(1,0.5)), selectPart21(4,0)) ;
voice2 = volume(6,ma.SR) * ba.selectmulti(ma.SR/10, par(i, 18, so.sound(s2, i).loop_speed_level(1,0.5)), selectPart21(6,ma.SR)) ;

playerVoice = voice1 , voice2;




// Ququ
Ququ = hgroup("QUQU", os.osc(freq): ringmod : AsrEnvelop <:volumebird);


freq = hslider("Frequency [unit:Hz] ", 4000, 70, 5000, 0.01):si.smooth(0.999);

ringmod = _<:_,*(os.oscs(freq)):drywet
		with {
            freq = hslider ( "Modulation Frequency[scale:log]", 97,0.001,100,0.001):si.smooth(0.999);
            drywet(x,y) = (1-c)*x + c*y;
            c = hslider("Modulation intensity[style:knob][unit:%]", 70,0,100,0.01)*(0.01):si.smooth(0.999);
        }; 

autoTrig = ba.beat(t) * (abs(no.noise) <= p) : trigger(4800) 
	with {
		t = hslider("Speed[style:knob][acc:0 1 -10 0 10]", 250, 120, 480, 0.1) : si.smooth(0.999);
		p = hslider("Probability[unit:%][style:knob][acc:0 1 -10 0 10]", 90, 25, 100, 1)*(0.01) : si.smooth(0.999);
		trigger(n) 	= upfront : release(n) : >(0.0) 
		with {
			upfront(x) 	= (x-x') > 0.0;
			decay(n,x)	= x - (x>0.0)/n;
			release(n)	= + ~ decay(n);
			};
		};

AsrEnvelop = *(en.asr(a,s,r,autoTrig)):_

    with {
        a = hslider("Envelope Attack[unit:s][style:knob]", 0.03, 0.01, 2, 0.01) : si.smooth(0.999);
        s = 1;
        r = hslider("Envelope Release[unit:s][style:knob]", 0.04, 0.01, 5, 0.01) : si.smooth(0.999);
       
        //t=ba.pulsen(hslider("Envelope Period", 6000, 0, 44100, 1), hslider("Envelope Length", 15000, 0, 44100, 1)); 
        //t = ba.beat (hslider("Speed [style:knob]", 120, 0, 480, 0.1) );
		p = hslider("Probability (Granulator)[unit:%][style:knob][acc:0 1 -10 0 10]", 90, 25, 100, 1)*(0.01) : si.smooth(0.999);
    };

volumebird = par(i,2,*(hslider("Volume", 0.02, 0, 1, 0.01):si.smooth(0.999)));


// Birdy from Grame playground
Birds = hgroup("Birds", mainOsc(noteTrig : rdm(72,94) : mtof , noteTrig) * envWrapper(noteTrig, ampEnv, amp_xp(2510)) : fi.lowpass(1, 2000) *(0.8) <: _,_, (rdmPanner : panSte) : panConnect : *,* : reverb);

// AUTO TRIGGER

autoTriger = ba.beat(t) * (abs(no.noise) <= p) : trigger(48) //tempo(2.5*t))
	with {
		t = hslider("[1]Speed (Granulator)[style:knob][acc:0 1 -10 0 10]", 120, 120, 480, 0.1) : si.smooth(0.999);
		p = hslider("[2]Probability (Granulator)[unit:%][style:knob][acc:1 0 -10 0 10]", 30, 25, 100, 1)*(0.01) : si.smooth(0.999);
		trigger(n) 	= upfront : release(n) : >(0.0) with {
			upfront(x) 	= (x-x') > 0.0;
			decay(n,x)	= x - (x>0.0)/n;
			release(n)	= + ~ decay(n);
		};
	};


// BIRD TRIGGER

noteTrig = autoTriger : min(1.0);
//noteTrig = autoTrig;


// OSCILLATORS - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  

/* base */
carrierOsc(freq) = os.osci(freq);
modOsc(freq) = os.triangleN(3,freq);

/* fm oscillator */
mainOsc(freq,trig) = freq <: +(*(harmRatio <: +(*(envWrapper(trig,harmEnv,harm_xp(1700))))) : modOsc : *(modIndex <: +(*(envWrapper(trig,modIndexEnv,modIndex_xp(550)))))) <: +(*(envWrapper(trig,freqEnv,freq_xp(943)))) : carrierOsc;

envWrapper(trig,env,sus) = trig : mstosamps(rdm(100,3000)), sus : hitLength : env;

// FIXED PARAMETERS - - - - - - - - - - - - - - - - - - - - - - - - - - - 

/* fm */
harmRatio = 0.063;
modIndex = 3.24;

// TIME FUNCTIONS - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

metro(ms) =  (%(+(1),mstosamps(ms))) ~_ : ==(1);
mstosamps(ms) = ms : /(1000) * ma.SR : int;
rdmInc = _ <: @(1), @(2) : + : *(2994.2313) : int : +(38125); 
rdm(rdmin,rdmax) = _,(fmod(_,rdmax - rdmin : int) ~ rdmInc : +(rdmin)) : gater : -(1) : abs;
gater = (_,_,_ <: !,_,!,_,!,!,!,!,_ : select2) ~_;

// MIDI RELATED - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

/* midi pitch */ 
mtof(midinote) = pow(2,(midinote - 69) / 12) * 440;

// ENVELOPPES - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

/* envelope "reader" (phaser) */

hitLength(length,sustain) = *((==(length,@(length,1))), +(1))~_ <: gater(<(sustain));

/* amplitude envelope */

ampEnvbpf = ba.bpf.start(0, 0) : 
	ba.bpf.point(amp_xp(60.241), 1.) : 
	ba.bpf.point(amp_xp(461.847), 0.) :
	ba.bpf.point(amp_xp(582.329), 0.928) : 
	ba.bpf.point(amp_xp(682.731), 0.5) : 
	ba.bpf.point(amp_xp(983.936), 0.) : 
	ba.bpf.point(amp_xp(1064.257), 0.) : 
	ba.bpf.point(amp_xp(1345.382), 0.) : 
	ba.bpf.point(amp_xp(1526.105), 0.) : 
	ba.bpf.point(amp_xp(1746.988), 0.) : 
	ba.bpf.point(amp_xp(1827.309), 0.) : 
	ba.bpf.point(amp_xp(2088.353), 0.) : 
	ba.bpf.point(amp_xp(2188.755), 0.) : /* sustain point */
	ba.bpf.end(amp_xp(2510.040), 0.);

ampEnv = ampEnvbpf : si.smooth(0.999) : fi.lowpass(1, 3000);
amp_xp(x) = x * ma.SR / 1000. * ampEnv_speed;
ampEnv_speed = noteTrig : rdm(0,2000) : /(1000);

/* freq envelope */

freqEnvbpf =  ba.bpf.start(0, 0) : 
	ba.bpf.point(freq_xp(147.751), 1.) : 
	ba.bpf.point(freq_xp(193.213), 0.) : 
	ba.bpf.point(freq_xp(318.233), yp) : 
	ba.bpf.point(freq_xp(431.888), 0.) : 
	ba.bpf.point(freq_xp(488.715), 0.434) : 
	ba.bpf.point(freq_xp(613.735), yp) : 
	ba.bpf.point(freq_xp(659.197), 1.) : 
	ba.bpf.point(freq_xp(716.024), yp) : 
	ba.bpf.point(freq_xp(806.948), 1.) : 
	ba.bpf.point(freq_xp(829.679), yp) : /* sustain point */
	ba.bpf.end(freq_xp(943.333), 0.);

freqEnv = freqEnvbpf : si.smooth(0.999) : fi.lowpass(1, 3000);
freq_xp(x) = x * ma.SR / 1000. * freqEnv_speed;
freqEnv_speed = noteTrig : rdm(0,2000) : /(1000);
yp = noteTrig : rdm(0,1000) : /(1000);

/* harmRatio envelope */

harmEnvbpf = ba.bpf.start(0, 0.) : 
	ba.bpf.point(harm_xp(863.454), 0.490) : 
	ba.bpf.point(harm_xp(865), 0.) : 
	ba.bpf.point (harm_xp(1305.221), 1.) : 
	ba.bpf.point(harm_xp(1646.586), 0.) : /* sustain point */
	ba.bpf.end(harm_xp(1700), 0.);

harmEnv = harmEnvbpf : si.smooth(0.999) : fi.lowpass(1, 3000);
harm_xp(x) = x * ma.SR / 1000. * harmEnv_speed;
harmEnv_speed = noteTrig : rdm(0,2000) : /(1000);

/* modIndex envelope */

modIndexEnvbpf = ba.bpf.start(0, 0.) : 
	ba.bpf.point(modIndex_xp(240.964), 0.554) : 
	ba.bpf.point(modIndex_xp(502.068), 0.) : /* sustain point */
	ba.bpf.end(modIndex_xp(550), 0.);

modIndexEnv = modIndexEnvbpf : si.smooth(0.999) : fi.lowpass(1, 3000);
modIndex_xp(x) = x * ma.SR / 1000. * modIndexEnv_speed;
modIndexEnv_speed = noteTrig : rdm(0,2000) : /(1000);

// PANNER STEREO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

panSte = _ <: -(1,_),_ : sqrt,sqrt;
rdmPanner = noteTrig : rdm(0,1000) : /(1000);

/* cable crosser = 1,3 & 2,4 */
panConnect = _,_,_,_ <: _,!,!,!,!,!,_,!,!,_,!,!,!,!,!,_;

// REVERB BASED OF ZITA - - - - - - - - - - - - - - - - - - - - - - - - - -

reverb(x,y) = re.zita_rev1_stereo(rdel,f1,f2,t60dc,t60m,fsmax,x,y)
	  : out_eq : dry_wet(x,y) : out_level
with {

  fsmax = 48000.0;  // highest sampling rate that will be used
  rdel = 60;
  f1 = 200;
  t60dc = 3;
  t60m = 2;
  f2 = 6000;
  out_eq = pareq_stereo(eq1f,eq1l,eq1q) : pareq_stereo(eq2f,eq2l,eq2q);

  pareq_stereo(eqf,eql,Q) = fi.peak_eq_rm(eql,eqf,tpbt), fi.peak_eq_rm(eql,eqf,tpbt)
  with {
    tpbt = wcT/sqrt(max(0,g)); // tan(ma.PI*B/ma.SR), B bw in Hz (Q^2 ~ g/4)
    wcT = 2*ma.PI*eqf/ma.SR;  // peak frequency in rad/sample
    g = ba.db2linear(eql); // peak gain
  };

  eq1f = 315;
  eq1l = 0;
  eq1q = 3;
  eq2f = 1500;
  eq2l = 0.0;
  eq2q = 3.0; 

  //out_group(x)  = x; //fdn_group(hgroup("[5] Output", x));

  dry_wet(x,y) = *(wet) + dry*x, *(wet) + dry*y with {
    wet = 0.5*(drywet+1.0);
    dry = 1.0-wet;
  };

  presence = hslider("[3]Proximity (InstrReverb)[style:knob][acc:1 0 -15 0 10]", 0.5, 0, 1, 0.01) : si.smooth(0.999);

  drywet = 1 - 2*presence;
  out_level = *(gain),*(gain);

  //gain = vslider("[5]Reverberation Volume[unit:dB][style:knob]", -20, -70, 20, 0.1)
  gain = -30 : +(6*presence) : ba.db2linear : si.smooth(0.999);
};


