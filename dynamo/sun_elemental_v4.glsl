
// dynamo210 beat/light sync GLSL function generator by QM (April 2021, corona fuck yeah)
// usage: get current beat by
// float B =_beat(iTime);
// depending on the nature of stuff, you might need a constant offset like iTime - 0.05, idk
// then call your curve functions with argument B

float smstep(float a, float b, float x) {return smoothstep(a, b, clamp(x, a, b));}
float theta(float x) { return smstep(0.,1e-3,x); }
float _t_[24] = float[24](0.,3.2603,6.4331,9.5177,12.5141,15.4218,18.2410,20.9719,23.6147,26.1700,28.6384,31.0207,33.3179,35.5309,37.6611,39.7099,41.6785,43.5687,176.9020,177.9116,179.0813,180.3687,181.7357,195.7194);
float _b_[24] = float[24](0.,4.,8.,12.,16.,20.,24.,28.,32.,36.,40.,44.,48.,52.,56.,60.,64.,68.,356.,358.,360.,362.,364.,384.);
float _fac_[24] = float[24](147.4761,142.5062,137.8185,133.4833,129.3349,125.4976,121.7915,118.4117,115.1953,112.1303,109.2689,106.5887,104.0469,101.6839,99.4390,97.3295,95.3484,2.1600,-12.4144,-18.0975,-27.9740,-45.1443,1.4302,1.4302); // fac is bps for flat segments, else... something else.
float _slope_[24] = float[24](0.0082,0.0087,0.0093,0.0099,0.0105,0.0111,0.0118,0.0126,0.0134,0.0142,0.0151,0.0160,0.0170,0.0181,0.0192,0.0205,0.0217,0.,-0.1740,-0.1001,-0.0576,-0.0332,0.,0.);
float _beat(float t)
{
    int it; for(it = 0; it < 23 && _t_[it + 1] < t; it++);
    if (_slope_[it] == 0.) return _b_[it] + (t - _t_[it]) * _fac_[it];
    return _b_[it] + _fac_[it] * (exp(_slope_[it]*(t - _t_[it])) - 1.);
}
float FOUR_ON_FLOOR(float b)
{
    float r = 0.;
    r += 0.9889 * pow(mod(b, 1.0), 0.0020) * exp(-0.2000*mod(b, 1.0));
    return r * theta(b);
}